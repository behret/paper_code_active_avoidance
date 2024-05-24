    %% prepare data
    speed_control = 0;
    
    [av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
        prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);
    
    [q, trial_idx_ses, ~, ~, ~, ~] = dr_into_joint_subspace(p, av_trials_all, err_trials_all, trans_data_all_dr, n_pc);
    
    [av_trials, err_trials, av_trials_iti, err_trials_iti, av_trials_dr, err_trials_dr, trans_data_dr, tone_idx_cat] = ...
        organize_trials_ae_iti(p, av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, q, trial_idx_ses,...
        aa_sessions, trans_data_all_dr, tone_idx);
    
    %% get motion dims 
    spd_dims = get_speed_dims_task_balance(p,trans_data_all_dr,q);

    % project trial data into motion nullspace
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
    [ removal_accs{rep}, dec_dims ] = ...
        ae_iterative_removal(p,av_trials_null,err_trials_null,n_dc_rep_time_independent,2,rand_control,precomputed,time_dependent,n_tr,tone_idx_cat);
    % project dec dims from speed nullspace back to joint coding subspace
    ae_dims_org = nullspace * dec_dims;
    
    %% get tone dim
    nullspace = null([spd_dims(:,1:2) ae_dims_org(:,1:2)]');    
    
    t_pool_tone = prepare_data_tone_decoding(p, traces, evs, bvs, tis);
    t_pool_tone = project_trial_set_into_one_subspace(p,t_pool_tone,[],q);
    
    % get dims with time-independent decoder
    precomputed_dims = [];
    time_dependent = 0;
    rand_control = 0;
    [ ~, dec_dims,~,~ ] = tone_iterative_removal(p,t_pool_tone,n_dc_rep_time_independent,2,rand_control,precomputed_dims,time_dependent,n_tr,nullspace);

    % collect dims
    tone_dims_org = nullspace * dec_dims;

    %% organize residual dims with PCA
    t_avs_a = nanmean(av_trials,3);
    t_avs_e = nanmean(err_trials,3);    
    y_ld = cat(2,t_avs_a,t_avs_e)';
    y_ld = y_ld - mean(y_ld);
    
    % nullspace projection
    nullspace = null([spd_dims(:,1:2) ae_dims_org(:,1:2) tone_dims_org(:,1)]');
    y_rem = y_ld*nullspace; % low d with AE dim removed
    
    % run PCA on y_rem 
    [u,s,v] = svd(y_rem');
    res_dims_org = nullspace * u;
    
    %% collect all dimensions
    dims = [spd_dims(:,1:2) ae_dims_org(:,1:2) tone_dims_org(:,1) res_dims_org];
