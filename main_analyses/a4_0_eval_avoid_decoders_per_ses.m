clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;


%% run DR and decoding procedure for different trial samples
fpath = fullfile(p.data_dir,'eval_avoid_decoders_per_ses');
saveData = 1;
saveFigs = 1;
n_rep = 80; 
n_rep_eval = 20;
n_dc_rep_time_independent = 10;
aa_sessions = 3:9;
% default number of trials
n_tr = 190; % needs to be lower here since we split in train and test
n_pc = 10;

eval_accs_1 = [];
eval_accs_2 = [];

for rep = 1:n_rep
    tic
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

    %% evaluate for dim 1
    this_eval_accs = eval_ae_decoder_per_ses( p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,aa_sessions,n_tr,nullspace,n_rep_eval,trans_data_all_dr,0,tone_idx);
    eval_accs_1 = cat(4,eval_accs_1,this_eval_accs);
    
    %% evaluate for dim 2:
    % first get ae dim as usual
    av_trials_null = [];
    err_trials_null = [];
    for t = 1:size(av_trials,2) % loop over time as it's the same for a/e
        av_trials_null(:,t,:) = nullspace' * squeeze(av_trials(:,t,:));
        err_trials_null(:,t,:) = nullspace' * squeeze(err_trials(:,t,:));
    end
    
    time_dependent = 0;
    precomputed = [];
    rand_control = 0;
    [ ~, dec_dims ] = ...
        ae_iterative_removal(p,av_trials_null,err_trials_null,n_dc_rep_time_independent,2,rand_control,precomputed,time_dependent,n_tr,tone_idx_cat);
    % project dec dims from speed nullspace back to joint coding subspace
    ae_dims_org = nullspace * dec_dims;

    % then add it to nullspace for evaluation
    nullspace = null([spd_dims(:,1:2) ae_dims_org(:,1)]');    
    this_eval_accs = eval_ae_decoder_per_ses( p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,aa_sessions,n_tr,nullspace,n_rep_eval,trans_data_all_dr,0,tone_idx);
    eval_accs_2 = cat(4,eval_accs_2,this_eval_accs);
    
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end


%% save

if saveData
    save(fpath,'eval_accs_1','eval_accs_2')
end

%%
plots_a4_0