function [ accs, dec_dims, weights,ve ] = tone_iterative_removal(p,t_pool_tone,n_rep,n_iter,rand_control,precomputed_dims,time_dependent,n_tr,nullspace)

    % project data into motion / avoid nullspace
    tone_null = [];
    for t = 1:size(t_pool_tone,2) % loop over time
        tone_null(:,t,:) = nullspace' * squeeze(t_pool_tone(:,t,:));
    end

    % predetermine random dims to remove
    if rand_control
        n_dims = size(tone_null,1);
        rand_dim = rand(1,n_dims)*2-1;
        rand_dim = rand_dim/norm(rand_dim);
        precomputed_dims = null(rand_dim);
    end
    
    % run iterative removal
    dec_dims = [];
    accs = [];
    weights = {};
    for i = 1:n_iter
        if i == 1
            this_tone = tone_null;
        else 
            if ~isempty(precomputed_dims)
                nullspace = null(precomputed_dims(:,1:i-1)');
            else
                nullspace = null(dec_dims');
            end
            % project data into nullspace
            this_tone = [];
            for t = 1:size(t_pool_tone,2) % loop over time
                this_tone(:,t,:) = nullspace' * squeeze(tone_null(:,t,:));
            end
        end
                
        if time_dependent
            [this_acc, weights{i}] = get_tone_decoding_acc(this_tone,n_tr,n_rep);
        else
            [this_acc, this_dec_dim ] = get_tone_decoding_dim_time_independent(this_tone,n_tr,n_rep);
        end
        accs = cat(3,accs,this_acc);
        
        if isempty(precomputed_dims)
            if i == 1
                this_dim = this_dec_dim;
            else
                this_dim = nullspace * this_dec_dim;
            end
            dec_dims = cat(2,dec_dims,this_dim);
        end
    end
    
    ve = [];
    if ~isempty(precomputed_dims)
        t_av = nanmean(tone_null,3);
        org = t_av';
        org = org - mean(org);
        for i = 1:n_iter
            rec = org*precomputed_dims(:,i)*precomputed_dims(:,i)';
            ve(i) = 100*(1 - norm(org-rec,'fro')^2  / norm(org,'fro')^2);
        end
    end
end