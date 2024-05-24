clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%% run DR and decoding procedure for different trial samples
fpath = fullfile(p.data_dir,'ae_decoding_weight_analysis');
saveData = 1;
saveFigs = 1;
n_rep = 80; % 160s
n_dc_rep = 10;
aa_sessions = 3:9;
n_pc = 10;
% default number of trials
n_tr = 300; 

%% collect data
time_accs = [];
time_accs_null = [];
time_accs_iti = [];
weight_corrs = [];
weight_corrs_null = [];
weight_corrs_iti = [];

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
    
    %% first get time dependent decoders for cross-temporal weight analysis
    this_time_acc = {};
    weights = {};
    [ this_time_acc{1},~,weights{1} ] = get_ae_decoding_dim(p,av_trials,err_trials,n_dc_rep,n_tr,0,tone_idx);    
    [ this_time_acc{2},~,weights{2} ] = get_ae_decoding_dim(p,av_trials_null,err_trials_null,n_dc_rep,n_tr,0,tone_idx);
    [ this_time_acc{3},~,weights{3} ] = get_ae_decoding_dim(p,av_trials_iti,err_trials_iti,n_dc_rep,n_tr,0,[]);

    %% analyze weights (doesnt make sense to compare weights over reps, 
    % but it does make sense to compare weight corrs)
    this_weight_corrs = {};
    for config = 1:3
        weight_cat = weights{config};
        this_weight_corrs{config} = [];
        for i = 1:size(weight_cat,2)
            for j = 1:size(weight_cat,2)
                c1 = weight_cat(:,i)';
                c2 = weight_cat(:,j)';
                c1 = c1/norm(c1);
                c2 = c2/norm(c2);
                cc = corrcoef(c1, c2);
                this_weight_corrs{config}(i,j) = cc(1,2);
            end
        end
    end

    %% collect data
    time_accs = cat(3,time_accs,this_time_acc{1});
    time_accs_null = cat(3,time_accs_null,this_time_acc{2});
    time_accs_iti = cat(3,time_accs_iti,this_time_acc{3});

    weight_corrs = cat(3,weight_corrs,this_weight_corrs{1});
    weight_corrs_null = cat(3,weight_corrs_null,this_weight_corrs{2});
    weight_corrs_iti = cat(3,weight_corrs_iti,this_weight_corrs{3});
    
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

%% save data
if saveData
    clear traces
    save(fpath)
end

%% 

plots_a1_x2_2
