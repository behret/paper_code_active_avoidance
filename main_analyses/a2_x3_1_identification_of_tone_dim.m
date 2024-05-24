clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%% run DR and decoding procedure for different trial samples
fpath = fullfile(p.data_dir,'identification_of_tone_dim');
saveData = 1;
saveFigs = 1;
n_rep = 80; % ~80 sec. per rep
n_iter = 2;
n_iter_tone = 3;
n_dc_rep_time_independent = 10;
n_dc_rep = 5;
aa_sessions = 3:9;
% default number of trials
n_tr = 300; 
n_pc = 10;

all_qs = {};
all_dims = {};

removal_accs = {};
removal_accs_rand = {};
removal_accs_time = {};
tone_weights = {};
tone_dim_ves = {};
eval_accs = {};
for rep = 1:n_rep
    tic
    %% prepare data
    speed_control = 0;
    iti_control = 0;
    
    [av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
        prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);
    
    [q, trial_idx_ses, ~, ~, ~, ~] = dr_into_joint_subspace(p, av_trials_all, err_trials_all, trans_data_all_dr, n_pc);
    
    [av_trials, err_trials, av_trials_iti, err_trials_iti, av_trials_dr, err_trials_dr, trans_data_dr, tone_idx] = ...
        organize_trials_ae_iti(p, av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, q, trial_idx_ses,...
        aa_sessions, trans_data_all_dr, tone_idx);
    
   
    %% get motion dims 
    spd_dims = get_speed_dims_task_balance(p,trans_data_all_dr,q);
    
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
    rand_control = 0;
    [ ~, dec_dims ] = ...
        ae_iterative_removal(p,av_trials_null,err_trials_null,n_dc_rep_time_independent,n_iter,rand_control,precomputed,time_dependent,n_tr,tone_idx);
    % project dec dims from speed nullspace back to joint coding subspace
    ae_dims_org = nullspace * dec_dims;

   
    %% get tone dims
    null_dims = [spd_dims(:,1:2) ae_dims_org(:,1:2)];
    nullspace = null([spd_dims(:,1:2) ae_dims_org(:,1:2)]');    

    t_pool_tone = prepare_data_tone_decoding(p, traces, evs, bvs, tis);
    t_pool_tone = project_trial_set_into_one_subspace(p,t_pool_tone,[],q);
    
    % get dims with time-independent decoder
    precomputed_dims = [];
    time_dependent = 0;
    rand_control = 0;
    [ removal_accs{rep}, dec_dims,~,~ ] = tone_iterative_removal(p,t_pool_tone,n_dc_rep_time_independent,n_iter_tone,rand_control,precomputed_dims,time_dependent,n_tr,nullspace);
    
    % control: take random dimensions to see how that affects accs
    rand_control = 1;
    [ removal_accs_rand{rep}, ~,~,~ ] = tone_iterative_removal(p,t_pool_tone,n_dc_rep_time_independent,n_iter_tone,rand_control,precomputed_dims,time_dependent,n_tr,nullspace);

    % test how time independent decoder performs per time step
    eval_accs{rep} = eval_time_independent_decoder_per_timestep(t_pool_tone,n_dc_rep,n_tr,nullspace);
    
    % evaluate dim removal on all time steps by training time-dependent
    % decoders in nullspaces
    time_dependent = 1;
    precomputed_dims = dec_dims;
    rand_control = 0;
    [ removal_accs_time{rep}, ~, this_weights, tone_dim_ves{rep} ] = tone_iterative_removal(p,t_pool_tone,n_dc_rep,n_iter_tone,rand_control,precomputed_dims,time_dependent,n_tr,nullspace);
    tone_weights{rep} = this_weights{1}; % we only need the first set of weights (no removed dim)
    
    % collect dims
    tone_dims_org = nullspace * dec_dims;
    dims = [spd_dims(:,1:2) ae_dims_org(:,1:2) tone_dims_org(:,1)];
    all_dims{rep} = dims;
    

    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

%% save
if saveData
    clear traces
    save(fpath)
end

%% plot
plot_tone_dim_analyses
