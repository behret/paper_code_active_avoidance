function [ acc,ae_dim,weight_cat ] = get_ae_decoding_dim( p,t_pool_av,t_pool_err,n_rep,n_tr,shuffle_control,tone_idx)
    
    % - function for decoding ae based on collection of a and e trials
    % - trials might be expressed in subspaces / nullspaces
    % - decoding is repeated for multiple iterations, each iteration with a
    % different subsample of avoid trials (higher number than err trials)
    % - based on the resulting decoding weights we calculate a decoding
    % dimension using PCA in the weight space
    
    %% fit models
    n_i = size(t_pool_err,2);
    weights = {};
    acc = [];
    for rep = 1:n_rep
        for i = 1:n_i
            
            % per time step: exclude trials where the tone was already
            % turned off
            if ~isempty(tone_idx)
                this_av_pool = t_pool_av(:,:,tone_idx(:,i) == 1);
            else
                this_av_pool = t_pool_av;
            end
                
            rand_sample_av = randperm(size(this_av_pool,3));
            rand_sample_av = rand_sample_av(1:n_tr);
            rand_sample_err = randperm(size(t_pool_err,3));
            rand_sample_err = rand_sample_err(1:n_tr);

            av_data = squeeze(this_av_pool(:,i,rand_sample_av))';
            err_data = squeeze(t_pool_err(:,i,rand_sample_err))';

            if size(this_av_pool,1) == 1
                av_data = av_data';
                err_data = err_data';
            end
            
            x_train = cat(1,av_data,err_data);
            t_train = cat(1,ones(n_tr,1),zeros(n_tr,1));
            
            if shuffle_control
                t_train = t_train(randperm(length(t_train)));
            end

            % train cv model and get accs
            Mdl_cv = fitcsvm(x_train,t_train, 'KernelFunction','linear', ...
                'kFold',5, 'Standardize',true); 
            acc(rep,i) = 1-kfoldLoss(Mdl_cv);

            % single model for weight analyis
            Mdl{i} = fitcsvm(x_train,t_train, 'KernelFunction','linear', ...
                'Standardize',true); 
        end

        % extract linear weights from models and normalize   
        for i = 1:size(Mdl,2)
            weights{rep}(:,i) = Mdl{i}.Beta;
        end

    end

    %%
    weight_cat = cat(3,weights{:});
    weight_cat = mean(weight_cat,3);
    % THIS IS NOT REALLY USED ANYMORE!
    ae_dim = mean(weight_cat,2);
    ae_dim = ae_dim/norm(ae_dim);
    
end

