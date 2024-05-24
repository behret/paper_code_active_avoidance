function [ accs, dec_dims ] = ae_iterative_removal(p,t_pool_av,t_pool_err,n_rep,n_iter,rand_control,precomputed_dims,time_dependent,n_tr,tone_idx)

    % predetermine random dims to remove
    if rand_control
        n_dims = size(t_pool_av,1);
        rand_dim = rand(1,n_dims)*2-1;
        rand_dim = rand_dim/norm(rand_dim);
        rand_space = null(rand_dim);
    end

    dec_dims = [];
    accs = [];
    for i = 1:n_iter
        if i == 1
            this_a_pool = t_pool_av;
            this_e_pool = t_pool_err;
        else 
            if ~isempty(precomputed_dims)
                nullspace = null(precomputed_dims(:,1:i-1)');
            else
                nullspace = null(dec_dims');
            end
            % project data into nullspace
            this_a_pool = [];
            this_e_pool = [];
            for t = 1:size(t_pool_av,2) % loop over time as it's the same for a/e
                this_a_pool(:,t,:) = nullspace' * squeeze(t_pool_av(:,t,:));
                this_e_pool(:,t,:) = nullspace' * squeeze(t_pool_err(:,t,:));
            end
        end

        
        if time_dependent
            [ this_acc,ae_dim ] = get_ae_decoding_dim(p,this_a_pool,this_e_pool,n_rep,n_tr,0,tone_idx);
        else
            [ this_acc,ae_dim ] = get_ae_decoding_dim_time_independent(p,this_a_pool,this_e_pool,n_rep,n_tr,tone_idx);
        end
        accs = cat(3,accs,this_acc);
        
        if i == 1
            this_dim = ae_dim;
        else
            this_dim = nullspace * ae_dim;
        end
        
        if rand_control
            dec_dims = rand_space(:,1:i);
        else
            dec_dims = cat(2,dec_dims,this_dim);
        end
    end
end