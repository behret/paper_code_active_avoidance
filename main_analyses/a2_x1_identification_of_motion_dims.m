clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%%
fpath = fullfile(p.data_dir,'identification_of_motion_dims');
saveData = 1;
saveFigs = 1;
n_rep = 80;
aa_sessions = 3:9;
n_pc = 10;
% default number of trials
n_tr = 300; 

explained = [];
pc1_proj = [];
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

    %% get ITI data used for decdoing (i.e. av_trials_iti, but full length)
    t_pools = {};
    for sub = 1:p.nSubjects    
        t_pools{sub} = [];
        for ses = aa_sessions
            t_pools{sub} = cat(3,t_pools{sub},trans_data_all{sub,ses});
        end
    end
    trans_data_dc = project_trial_set_into_one_subspace(p,t_pools,[],q);
    
    %% calc VE for on DR and DC trial averages
    for i = 1:2
        if i == 1
            t_av = nanmean(trans_data_dr,3);
        else
            t_av = nanmean(trans_data_dc,3);
        end

        for pc = 1:size(spd_dims,2)
            org = t_av - mean(t_av')';
            rec = org' * spd_dims(:,pc) * spd_dims(:,pc)';
            explained(rep,i,pc) = 100*(1 - norm(org-rec','fro')^2  / norm(org,'fro')^2);
        end
    end
    
    %% get PC1 projections for individual subjects
    
    for sub = 1:p.nSubjects    
        p_single = p;
        p_single.nSubjects = 1;
        this_trans_data_dc = project_trial_set_into_one_subspace(p_single,t_pools(sub),[],q(sub));
        t_av = nanmean(this_trans_data_dc,3);
        org = t_av - mean(t_av')';
        pc1_proj(rep,sub,:) = org' * spd_dims(:,1);
    end
    
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end


%% get actual speed for example rep
speed_control = 1;

[av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
    prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);

all_iti = cat(3,trans_data_all_dr{:,3:9});
mn_iti_spd = mean(mean(all_iti,3));


%% save
% explained is quantified over reps, the other two are plotted for example
% reps

if saveData
    save(fpath,'explained','trans_data_dr','mn_iti_spd','spd_dims','pc1_proj')
end

%%
plots_a2_x1

