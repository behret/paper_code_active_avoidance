% here we further analyze how consistent the neural dynamics of individual
% subjects is with the found joint one

clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')

%%
fpath = fullfile(p.data_dir,'dr_validation');
saveData = 1;
saveFigs = 1;
n_rep = 80;
speed_control = 0;
n_pc = 20;

%% 

subject_ves = {};
joint_ves = {};
dim_sims = {};
projs = {};

for rep = 1:n_rep
    tic
    [av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
        prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);
    
    [q, trial_idx_ses, subject_ves{rep}, joint_ves{rep}, dim_sims{rep}, projs{rep}] = ...
        dr_into_joint_subspace(p, av_trials_all, err_trials_all, trans_data_all_dr, n_pc);

    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

if saveData
    save(fpath,'subject_ves','joint_ves','dim_sims','projs')
end
