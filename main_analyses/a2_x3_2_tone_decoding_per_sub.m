clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%% run DR and decoding procedure for different trial samples
fpath = fullfile(p.data_dir,'tone_decoding_per_sub');
saveData = 1;
saveFigs = 1;
n_rep = 20; % ~80 sec. per rep
n_iter = 2;
n_iter_tone = 3;
n_dc_rep_time_independent = 10;
n_dc_rep = 5;
aa_sessions = 3:9;
% default number of trials
n_tr = 300; 
n_pc = 10;

mean_acc = [];

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

   
    %% organize data
    t_pool_tone = prepare_data_tone_decoding(p, traces, evs, bvs, tis);
    
    null_dims = [spd_dims(:,1:2) ae_dims_org(:,1:2)];
    nullspace = null([spd_dims(:,1:2) ae_dims_org(:,1:2)]');

    % split into train and test
    train_pool = [];
    test_pools = {};
    for sub = 1:p.nSubjects
        rand_idx = randperm(size(t_pool_tone{sub},3));
        n_tr_tone = floor(length(rand_idx)/2);
        this_test_pool = t_pool_tone{sub}(:,:,rand_idx(1:n_tr_tone));
        this_train_pool = t_pool_tone{sub}(:,:,rand_idx(n_tr_tone+1:end));
        % project to subspace
        proj_p = p;
        proj_p.nSubjects = 1;
        this_test_pool = project_trial_set_into_one_subspace(proj_p,{this_test_pool},[],q(sub));
        this_train_pool = project_trial_set_into_one_subspace(proj_p,{this_train_pool},[],q(sub));
        % collect
        train_pool = cat(3,train_pool,this_train_pool);
        test_pools{sub} = this_test_pool;
    end
    
    %% project data into motion / avoid nullspace
    tone_null = [];
    for t = 1:size(train_pool,2) % loop over time
        tone_null(:,t,:) = nullspace' * squeeze(train_pool(:,t,:));
    end
    train_pool = tone_null;
    
    for sub = 1:p.nSubjects
        tone_null = [];
        for t = 1:size(test_pools{sub},2) % loop over time
            tone_null(:,t,:) = nullspace' * squeeze(test_pools{sub}(:,t,:));
        end
        test_pools{sub} = tone_null;
    end
    
    %% train
    n_tr_tone = floor(size(train_pool,3)/2);
    rand_idx = randperm(size(train_pool,3));
    tone_tr = rand_idx(1:n_tr_tone);
    bl_tr_pre = rand_idx(n_tr_tone+1:2*n_tr_tone);

    tone_samples = [];
    bl_samples = [];
    for i = 1:n_tr_tone
        % for tone we have to cut the 5 time steps before tone start
        % and after tone end -> sample 1 to 25 and do +5            
        rand_time = randi(25);
        this_tone_sample = train_pool(:,5+rand_time,tone_tr(i));
        tone_samples = cat(2,tone_samples,this_tone_sample);

        % take random t for pre tone
        rand_time = randi(4);
        this_bl_sample = train_pool(:,rand_time,bl_tr_pre(i));
        bl_samples = cat(2,bl_samples,this_bl_sample);
    end

    % fit models
    x_train = cat(1,tone_samples',bl_samples');
    t_train = cat(1,ones(n_tr_tone,1),zeros(n_tr_tone,1));

    % single model for weight analyis
    Mdl = fitcsvm(x_train,t_train, 'KernelFunction','linear', ...
        'Standardize',true); 
    
    
    %% eval
    for sub = 1:p.nSubjects
        % split trials into tone and bl trials (as for training)
        rand_idx = randperm(size(test_pools{sub},3));
        n_tr_tone = floor(length(rand_idx)/2);
        tone_tr_test = rand_idx(1:n_tr_tone);
        bl_tr_pre_test = rand_idx(n_tr_tone+1:2*n_tr_tone);
        
        preds = [];
        for tr = 1:n_tr_tone
            for i = 1:size(tone_null,2)
                preds(tr,i,1) = predict(Mdl,test_pools{sub}(:,i,tone_tr_test(tr))');
                rand_time = randi(4);
                preds(tr,i,2) = 1-predict(Mdl,test_pools{sub}(:,rand_time,bl_tr_pre_test(tr))');
            end
        end
        mean_acc(rep,sub,:) = squeeze(mean(mean(preds,3)));
    end
    
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

%% save
if saveData
    save(fpath,'mean_acc')
end

%%
plots_a2_x3_2