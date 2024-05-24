function [ mean_proj_a,mean_proj_e,dim_vars,dim_ves, d_primes ] = ...
    analyze_dims_over_sessions(p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,dims,q,trial_idx_ses)

    n_dims = size(dims,2);

    % analyze summary dims over sessions
    % - calc mean projections for a and e per session
    % - quantify VE using a/e mean projs
    % - calculate d-prime for a/e discrimination for every dimension
    
    %% get mean projections and calc VE 
    dim_ves = [];
    dim_vars = [];
    mean_proj_a = [];
    mean_proj_e = [];
    for ses = 1:p.nSessions
        % project and concat data per session
        [ av_trials, err_trials] = ...
            get_full_ae_trials_in_subspace(p, av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,ses);

        % build trial average in subspace
        t_av_av = nanmean(av_trials,3)';
        t_av_err = nanmean(err_trials,3)';

        % project onto summary dims and calculate VE
        for i = 1:n_dims
            org = cat(1,t_av_av,t_av_err);
            org = org - mean(org);
            rec = org * dims(:,i) * dims(:,i)';
            this_ve = 100*(1 - norm(org-rec,'fro')^2  / norm(org,'fro')^2);
            dim_ves(ses,i) = this_ve;
            %dim_vars(ses,i) = norm(rec,'fro');
            dim_vars(ses,i) = var(org * dims(:,i));

            mean_proj_a(ses,i,:) = t_av_av * dims(:,i);
            mean_proj_e(ses,i,:) = t_av_err * dims(:,i);
        end
    end


    %% calc d-prime
    d_primes = [];
    for ses = 1:p.nSessions
        % project and concat data per session
        %[ av_trials, err_trials, ~, ~, ~, ~, ~ ] = ...
        %organize_trials_ae_iti(p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,cell_means,trial_idx_ses,ses);
        [ av_trials, err_trials] = ...
            get_full_ae_trials_in_subspace(p, av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,ses);
        
        % calc d-prime: first project trials per dimension, then calc mean
        % and SD
        for d = 1:n_dims
            % project trials
            a_proj = [];
            for tr = 1:size(av_trials,3)
                a_proj(:,tr) = av_trials(:,:,tr)' * dims(:,d);
            end
            e_proj = [];
            for tr = 1:size(err_trials,3)
                e_proj(:,tr) = err_trials(:,:,tr)' * dims(:,d);
            end   

            mn_diff = nanmean(a_proj,2) - nanmean(e_proj,2);
            sd_a = nanstd(a_proj,[],2);
            sd_e = nanstd(e_proj,[],2);
            joint_sd = (sd_a + sd_e) / 2;
            d_primes(ses,d,:) = mn_diff./joint_sd;
        end
    end
end

