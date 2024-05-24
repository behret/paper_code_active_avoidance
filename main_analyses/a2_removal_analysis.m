clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%% run DR and decoding procedure for different trial samples
fpath = fullfile(p.data_dir,'removal_analysis_one_subspace');
saveData = 1;
saveFigs = 1;
n_rep = 80;
n_dc_rep = 2;
n_iter = 5;
n_dc_rep_time_independent = 10;
rand_control = 0;
aa_sessions = 3:9;
n_pc = 10;
% default number of trials
n_tr = 300; 

removal_accs_time = {};
removal_accs = {};

for rep = 1:n_rep
    tic
    %% prepare data
    speed_control = 0;
    
    [av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
        prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);
    
    [q, trial_idx_ses, ~, ~, ~, ~] = dr_into_joint_subspace(p, av_trials_all, err_trials_all, trans_data_all_dr, n_pc);
    all_qs{rep} = q;

    [av_trials, err_trials, av_trials_iti, err_trials_iti, av_trials_dr, err_trials_dr, trans_data_dr, tone_idx] = ...
        organize_trials_ae_iti(p, av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, q, trial_idx_ses,...
        aa_sessions, trans_data_all_dr, tone_idx);    
    
    %% get motion dims 
    spd_dims = get_speed_dims_task_balance(p,trans_data_all_dr,q);
   
    %% quantify effect of removing spd dims on AE / ITI decoding
    time_dependent = 1;
    [ removal_accs_time{rep,1}, ~ ] = ae_iterative_removal(p,av_trials,err_trials,n_dc_rep,n_iter,rand_control,spd_dims,time_dependent,n_tr,tone_idx);
    [ removal_accs_time{rep,2}, ~ ] = ae_iterative_removal(p,av_trials_iti,err_trials_iti,n_dc_rep,n_iter,rand_control,spd_dims,time_dependent,n_tr,[]);
    
    %% project trial data into motion nullspace
    nullspace = null(spd_dims(:,1:2)');    
    av_trials_null = [];
    err_trials_null = [];
    av_trials_iti_null = [];
    err_trials_iti_null = [];
    for t = 1:size(av_trials,2) % loop over time as it's the same for a/e
        av_trials_null(:,t,:) = nullspace' * squeeze(av_trials(:,t,:));
        err_trials_null(:,t,:) = nullspace' * squeeze(err_trials(:,t,:));
        av_trials_iti_null(:,t,:) = nullspace' * squeeze(av_trials_iti(:,t,:));
        err_trials_iti_null(:,t,:) = nullspace' * squeeze(err_trials_iti(:,t,:));
    end
    
    %% get AE dims: train time-independent decoder for AE (iterative removal)
    time_dependent = 0;
    precomputed = [];
    [ removal_accs{rep}, dec_dims ] = ae_iterative_removal(p,av_trials_null,err_trials_null,n_dc_rep_time_independent,n_iter,rand_control,precomputed,time_dependent,n_tr,tone_idx);
    
    % project dec dims from speed nullspace back to joint coding subspace
    dec_dims_org = nullspace * dec_dims;

    %% evaluate dim removal for time-dependent AE (in motion nullspace) and time-dependent ITI (in original space)
    time_dependent = 1;
    [ removal_accs_time{rep,3}, ~ ] = ae_iterative_removal(p,av_trials_null,err_trials_null,n_dc_rep,n_iter,rand_control,dec_dims,time_dependent,n_tr,tone_idx);
    [ removal_accs_time{rep,4}, ~ ] = ae_iterative_removal(p,av_trials_iti,err_trials_iti,n_dc_rep,n_iter,rand_control,dec_dims_org,time_dependent,n_tr,[]);
    
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

% save
if saveData
    save(fpath,'removal_accs', 'removal_accs_time')
end

%%
plot_removal_results( removal_accs, removal_accs_time,saveFigs)