function [ eval_accs ] = eval_ae_decoder_per_sub( p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,aa_sessions,n_tr,nullspace,n_rep,trans_data_all_dr,rand_control,tone_idx)

%%
    for rep = 1:n_rep
        %% create two versions of trial_idx_ses: one for training, one for testing
        trial_idx_ses = cellfun(@(x) x(randperm(length(x))),trial_idx_ses,'UniformOutput',false);
        trial_idx_test = cellfun(@(x) x(1:floor(size(x,2)/2)),trial_idx_ses,'UniformOutput',false);
        trial_idx_train = cellfun(@(x) x(floor(size(x,2)/2)+1:end),trial_idx_ses,'UniformOutput',false);

        %% rerun trial orga for training
        [ av_trials, err_trials, av_trials_iti, err_trials_iti, av_trials_dr, err_trials_dr, trans_data_dr,tone_idx_cat ] = ...
            organize_trials_ae_iti(p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_train,aa_sessions,trans_data_all_dr,tone_idx);

        %% project into nullspace
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

        t_pool_av = av_trials_null;
        t_pool_err = err_trials_null;

        %% train decoder with all training data

        % sample trials
        rand_sample_av = randperm(size(t_pool_av,3));
        rand_sample_av = rand_sample_av(1:n_tr);
        rand_sample_err = randperm(size(t_pool_err,3));
        rand_sample_err = rand_sample_err(1:n_tr);

        % sample time points
        time_sample_av = randi(20,n_tr,1);
        time_sample_err = randi(20,n_tr,1);

        av_data = [];
        err_data = [];
        for i = 1:n_tr
            this_av = squeeze(t_pool_av(:,time_sample_av(i),rand_sample_av(i)))';
            this_err = squeeze(t_pool_err(:,time_sample_err(i),rand_sample_err(i)))';
            av_data = cat(1,av_data,this_av);
            err_data = cat(1,err_data,this_err);
        end

        x_train = cat(1,av_data,err_data);
        t_train = cat(1,ones(n_tr,1),zeros(n_tr,1));

        if rand_control
            t_train = t_train(randperm(length(t_train)));
        end
        
        % single model for weight analyis
        Mdl = fitcsvm(x_train,t_train, 'KernelFunction','linear', ...
            'Standardize',true); 

        %% test decoder per subject: 
        % run organize trials with test_idx and specific session
        % project to nullspace
        % make preds

        for sub = 1:p.nSubjects
            p_single = p;
            p_single.nSubjects = 1;
            
            if sub == 10
                sessions = 2:9;
            else
                sessions = 3:9;
            end
            % get test trials for this subject
            [ av_trials, err_trials, av_trials_iti, err_trials_iti, av_trials_dr, err_trials_dr, trans_data_dr,tone_idx_cat ] = ...
                organize_trials_ae_iti(p_single,av_trials_all(sub,:),err_trials_all(sub,:),trans_data_all(sub,:),...
                trans_data_err_all(sub,:),q(sub),trial_idx_test(sub,:,:,:),sessions,trans_data_all_dr(sub,:),tone_idx(sub,:));

            % project into nullspace
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

            t_pool_av = av_trials_null;
            t_pool_err = err_trials_null;

            
            preds = [];
            for tr = 1:size(t_pool_av,3)
                for ts = 1:size(t_pool_av,2)
                    preds(tr,ts) = predict(Mdl,t_pool_av(:,ts,tr)');
                end
            end
            % take average over av trials (keep time course)
            eval_accs(rep,sub,:,1) = mean(preds);
            
            preds = [];
            for tr = 1:size(t_pool_err,3)
                for ts = 1:size(t_pool_err,2)
                    preds(tr,ts) = 1-predict(Mdl,t_pool_err(:,ts,tr)');
                end
            end
            % take average over err trials (keep time course)
            eval_accs(rep,sub,:,2) = mean(preds);  
            
        end
    end
end

