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
fpath = fullfile(p.data_dir,'task_decoding_single_dim');
n_rep = 80; %  sec per rep
n_dc_rep = 10;
n_iter = 2;
n_dc_rep_time_independent = 10;
rand_control = 0;
aa_sessions = 3:9;
n_pc = 10;

n_tr = 300; 
n_tr_dc = 90; 

td_accs = {};

for rep = 1:n_rep
    tic
    
    %% do decomposition via script
    decomposition_script;
    
    %% do task decoding
    % get iti transitions where we only take transitions with the correct
    % ttype per task to control for the fact that motion is different for
    % av trials in T1 and T2
    % this is only used when we build the trial sets for decoding
    [trans_data_ttype] = prepare_data_task_decoding_iti(p, traces, evs, bvs, tis, speed_control);
    
    t1_session = 3:4;
    [ av_trials_t1, err_trials_t1, av_trials_iti_t1, err_trials_iti_t1, ~, ~, ~, ~ ] = ...
        organize_trials_ae_iti(p,av_trials_all,err_trials_all,trans_data_ttype,trans_data_err_all,q,trial_idx_ses,t1_session,trans_data_all_dr,tone_idx);
    t2_session = 6:9;
    [ av_trials_t2, err_trials_t2, av_trials_iti_t2, err_trials_iti_t2, ~, ~, ~, ~ ] = ...
        organize_trials_ae_iti(p,av_trials_all,err_trials_all,trans_data_ttype,trans_data_err_all,q,trial_idx_ses,t2_session,trans_data_all_dr,tone_idx);
 
    for config = 1:3
        switch config
            case 1
                trialset_1 = av_trials_t1;
                trialset_2 = av_trials_t2;
            case 2
                trialset_1 = err_trials_t1;
                trialset_2 = err_trials_t2;
            case 3
                trialset_1 = av_trials_iti_t1;
                trialset_2 = av_trials_iti_t2;           
            case 4
                [ shuttles_type1_t2, shuttle_times ] = get_t2_d1_shuttles(p, traces, evs, bvs, tis, speed_control,1);
                [ t_pool ] = project_trial_set_into_one_subspace(p,shuttles_type1_t2,[],q);
                trialset_1 = av_trials_t2;       
                trialset_2 = t_pool;
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

plots_a4_1
