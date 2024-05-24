clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;


%% run DR and decoding procedure for different trial samples
fpath = fullfile(p.data_dir,'eval_avoid_decoders_per_sub');
saveData = 1;
saveFigs = 0;
n_rep = 80; 
n_rep_eval = 2;
n_dc_rep_time_independent = 10;
aa_sessions = 3:9;
% default number of trials
n_tr = 190; % needs to be lower here since we split in train and test
n_pc = 10;

eval_accs = [];
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
    this_eval_accs = eval_ae_decoder_per_sub( p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,aa_sessions,n_tr,nullspace,n_rep_eval,trans_data_all_dr,0,tone_idx);
    eval_accs = cat(5,eval_accs,this_eval_accs);
    
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end


%% save

if saveData
    save(fpath,'eval_accs')
end


%%

plots_a2_x2_3

