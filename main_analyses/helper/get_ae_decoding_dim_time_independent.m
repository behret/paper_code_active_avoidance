function [ acc,ae_dim,weights ] = get_ae_decoding_dim_time_independent( p,t_pool_av,t_pool_err,n_rep,n_tr,tone_idx)
    
    % - train one decoder for all time steps (sample time point per trial)
    % - function for decoding ae based on collection of a and e trials
    % - trials might be expressed in subspaces / nullspaces
    % - decoding is repeated for multiple iterations, each iteration with a
    % different subsample of avoid trials (higher number than err trials)

    %% fit models

    weights = {};
    acc = [];
    for rep = 1:n_rep
        % for every trial, sample a time point
        % for avoid trials, exclude data points where the tone was turned
        % off already
        av_data = [];
        rand_idx = randperm(size(t_pool_av,3));
        for tr = 1:n_tr
            this_trial_idx = rand_idx(tr);
            if isempty(tone_idx)
                max_idx = 20;
            else
                max_idx = find(tone_idx(this_trial_idx,:),1,'last');
            end
            this_time_idx = randi(max_idx);
            this_av = t_pool_av(:,this_time_idx,this_trial_idx);
            av_data = cat(2,av_data,this_av);
        end

        err_data = [];
        rand_idx = randperm(size(t_pool_err,3));
        for tr = 1:n_tr
            this_trial_idx = rand_idx(tr);
            this_time_idx = randi(20);
            this_err = t_pool_err(:,this_time_idx,this_trial_idx);
            err_data = cat(2,err_data,this_err);
        end
            
        x_train = cat(1,av_data',err_data');
        t_train = cat(1,ones(size(av_data,2),1),zeros(size(err_data,2),1));

        % train cv model and get accs
        Mdl_cv = fitcsvm(x_train,t_train, 'KernelFunction','linear','kFold',5,'Standardize',true); 
        acc(rep) = 1-kfoldLoss(Mdl_cv);

        % single model for weight analyis
        Mdl = fitcsvm(x_train,t_train, 'KernelFunction','linear','Standardize',true); 
        % extract linear weights from model
        weights{rep} = Mdl.Beta;
    end

    %%
    
    weight_cat = cat(2,weights{:});
    ae_dim = mean(weight_cat,2);
    ae_dim = ae_dim/norm(ae_dim);
    
end

