% - decode avoid trials between T1 and T2 in subspace
% - do DR into one subspace with overall concat
% - do spd and av removal analysis
% - do subspace decomp
% - then do task decoding with removal analysis code
clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%% run DR and decoding procedure for different trial samples

saveData = 1;
saveFigs = 1;
fpath = fullfile(p.data_dir,'single_dim_decoding_t2_trial_groups');
n_rep = 80; %  sec per rep
n_dc_rep = 10;
n_iter = 2;
n_dc_rep_time_independent = 10;
rand_control = 0;
aa_sessions = 3:9;
n_pc = 10;

n_tr = 300; 
n_tr_dc = 110; 

td_accs = {};

for rep = 1:n_rep
    tic

    %% do decomposition via script
    decomposition_script;
    
    %% do decoding of y xy
    % get t2 avoid trials with and without x-shuttle
    [ av_x,av_no_x ] = get_t2_avoid_trials_x(p, traces, evs, bvs, tis, 0);
    % project trials to subspace (usually done in organize_trials)
    t2_av_xy = project_trial_set_into_one_subspace(p,av_x,[],q);
    t2_av_y = project_trial_set_into_one_subspace(p,av_no_x,[],q);
   
    % get t2 error trials with and without x-shuttle
    [ shuttles,no_shuttles,shuttle_times ] = get_t2_d1_shuttles(p, traces, evs, bvs, tis, 0,1);
    % project trials to subspace (usually done in organize_trials)
    t2_err_x = project_trial_set_into_one_subspace(p,shuttles,[],q);
    t2_err_no_x = project_trial_set_into_one_subspace(p,no_shuttles,[],q);
    
    t1_session = 3:4;
    [ av_trials_t1, err_trials_t1, av_trials_iti_t1, err_trials_iti_t1, ~, ~, ~, ~] = ...
        organize_trials_ae_iti(p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,t1_session,trans_data_all_dr,tone_idx);
    t2_session = 6:9;
    [ av_trials_t2, err_trials_t2, av_trials_iti_t2, err_trials_iti_t2, ~, ~, ~, ~] = ...
        organize_trials_ae_iti(p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,t2_session,trans_data_all_dr,tone_idx);
 
    % 1: T2 y vs. xy -> difference is in motion, but not cog
    % 2: T1 av vs. T2 xy -> difference is in motion and cog
    for config = 1:2
        switch config
            case 1
                trialset_1 = t2_av_y;
                trialset_2 = t2_av_xy;
            case 2
                trialset_1 = av_trials_t1;
                trialset_2 = t2_av_xy; 
            otherwise
                disp('incorrect config')
        end
        
        % project data onto individual dims
        for d = 1:5
            trialset_1_dim = [];
            trialset_2_dim = [];
            for t = 1:size(trialset_1,2) % loop over time as it's the same for a/e
                trialset_1_dim(1,t,:) = dims(:,d)' * squeeze(trialset_1(:,t,:));
                trialset_2_dim(1,t,:) = dims(:,d)' * squeeze(trialset_2(:,t,:));
            end
            [ td_accs{rep,config,d}, ~, ~ ] = get_ae_decoding_dim(p,trialset_1_dim,trialset_2_dim,n_dc_rep,n_tr_dc,0,[]);
        end
        
        % also do once with all 5 dims for d=6
        [ td_accs{rep,config,6}, ~, ~ ] = get_ae_decoding_dim(p,trialset_1,trialset_2,n_dc_rep,n_tr_dc,0,[]);
    end
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

if saveData
    save(fpath,'td_accs')
end

%%
plots_a4_2
