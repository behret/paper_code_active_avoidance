function [eval_accs] = eval_ae_decoder_per_timestep(t_pool_av,t_pool_err,n_rep,n_tr,tone_idx)

    % - evaluate time-independent a/e decoder separately for each time step
    % to see how it compares to time-dependent decoders
    % - split trials: half for training, half for evaluating
    
    %%
    eval_accs = [];
    for rep = 1:n_rep
        
        %% train time-independent decoder
        % sample trials
        rand_sample_av = randperm(size(t_pool_av,3));
        av_trial_idx = rand_sample_av(1:n_tr);
        av_trial_idx_test = rand_sample_av(n_tr+1:n_tr*2);
        rand_sample_err = randperm(size(t_pool_err,3));
        err_trial_idx = rand_sample_err(1:n_tr);
        err_trial_idx_test = rand_sample_err(n_tr+1:n_tr*2);

        % for every trial, sample a time point
        % for avoid trials, exclude data points where the tone was turned
        % off already
        av_data = [];
        for tr = 1:n_tr
            this_trial_idx = av_trial_idx(tr);
            max_idx = find(tone_idx(this_trial_idx,:),1,'last');
            this_time_idx = randi(max_idx);
            this_av = t_pool_av(:,this_time_idx,this_trial_idx);
            av_data = cat(1,av_data,this_av');
        end

        err_data = [];
        for tr = 1:n_tr
            this_trial_idx = err_trial_idx(tr);
            this_time_idx = randi(20);
            this_err = t_pool_err(:,this_time_idx,this_trial_idx);
            err_data = cat(1,err_data,this_err');
        end
        
        x_train = cat(1,av_data,err_data);
        t_train = cat(1,ones(n_tr,1),zeros(n_tr,1));

        % train single model
        Mdl = fitcsvm(x_train,t_train, 'KernelFunction','linear', ...
            'Standardize',true); 
        
        %% evaluate model per time step
        % test for every time step in test trials
        preds = [];
        for tr = 1:n_tr
            for i = 1:size(t_pool_av,2)
                preds(tr,i,1) = predict(Mdl,t_pool_av(:,i,av_trial_idx_test(tr))');
                preds(tr,i,2) = 1-predict(Mdl,t_pool_err(:,i,err_trial_idx_test(tr))');
            end
        end
        eval_accs(rep,:) = squeeze(mean(mean(preds),3));
    end
end
