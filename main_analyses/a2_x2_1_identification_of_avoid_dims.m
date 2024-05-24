clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%% run DR and decoding procedure for different trial samples
fpath = fullfile(p.data_dir,'identification_of_avoid_dims');
saveData = 1;
saveFigs = 1;
n_rep = 80; % 110s
n_dc_rep = 10;
n_dc_rep_time_independent = 10;
n_iter = 5;
aa_sessions = 3:9;
n_pc = 10;
% THIS IS ADJUSTED HERE TO ALLOW EVALUATION OF TIME-INDEPENDENT DECODERS
n_tr = 150; 

%% collect data
all_time_accs = [];
all_eval_accs = [];
all_removal_accs = [];
all_removal_accs_rand = [];

for rep = 1:n_rep
    tic
    %% prepare data
    speed_control = 0;
    iti_control = 0;
    [av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
        prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);
    
    [q, trial_idx_ses, ~, ~, ~, ~] = dr_into_joint_subspace(p, av_trials_all, err_trials_all, trans_data_all_dr, n_pc);
    all_qs{rep} = q;

    [av_trials, err_trials, av_trials_iti, err_trials_iti, av_trials_dr, err_trials_dr, trans_data_dr, tone_idx] = ...
        organize_trials_ae_iti(p, av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, q, trial_idx_ses,...
        aa_sessions, trans_data_all_dr, tone_idx);   
    
    %% get motion dims 
    spd_dims = get_speed_dims_task_balance(p,trans_data_all_dr,q);

    % project trial data into motion nullspace
    nullspace = null(spd_dims(:,1:2)');    
    av_trials_null = [];
    err_trials_null = [];
    for t = 1:size(av_trials,2) % loop over time as it's the same for a/e
        av_trials_null(:,t,:) = nullspace' * squeeze(av_trials(:,t,:));
        err_trials_null(:,t,:) = nullspace' * squeeze(err_trials(:,t,:));
    end
    
    %% train time-independent decoder
    [eval_accs] = eval_ae_decoder_per_timestep(av_trials_null,err_trials_null,n_dc_rep,n_tr,tone_idx);
    
    %% train time-dependent decoders
    [ accs_time,~,~ ] = get_ae_decoding_dim( p,av_trials_null,err_trials_null,n_dc_rep,n_tr,0,tone_idx);
    
    %% run iterative removal (basic and rand control)
    time_dependent = 0;
    precomputed = [];
    rand_control = 0;
    [ removal_accs, ~ ] = ae_iterative_removal(p,av_trials_null,err_trials_null,n_dc_rep_time_independent,n_iter,rand_control,precomputed,time_dependent,n_tr,tone_idx);

    time_dependent = 0;
    precomputed = [];
    rand_control = 1;
    [ removal_accs_rand, ~ ] = ae_iterative_removal(p,av_trials_null,err_trials_null,n_dc_rep_time_independent,n_iter,rand_control,precomputed,time_dependent,n_tr,tone_idx);

    
    %% collect data
    all_time_accs = cat(3,all_time_accs,accs_time);
    all_eval_accs = cat(3,all_eval_accs,eval_accs);
    all_removal_accs = cat(1,all_removal_accs,removal_accs);
    all_removal_accs_rand = cat(1,all_removal_accs_rand,removal_accs_rand);
    
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

%% save
if saveData
    save(fpath,'all_time_accs','all_eval_accs','all_removal_accs','all_removal_accs_rand')
end

%%
plot_av_dim_time_independent_vs_dependent

