function [mean_proj,dim_vars,dim_ves] = ...
    analyze_dims_over_sessions_iti(p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,dims,q,trial_idx_ses)
   
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
        [ av_trials, err_trials, trans_data] = ...
            get_full_ae_trials_in_subspace(p, av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,ses);

        % build trial average in subspace
        t_av = nanmean(trans_data,3)';

        % project onto summary dims and calculate VE
        for i = 1:n_dims
            org = t_av;
            org = org - mean(org);
            rec = org * dims(:,i) * dims(:,i)';
            this_ve = 100*(1 - norm(org-rec,'fro')^2  / norm(org,'fro')^2);
            dim_ves(ses,i) = this_ve;
            %dim_vars(ses,i) = norm(rec,'fro');
            dim_vars(ses,i) = var(org * dims(:,i));
            mean_proj(ses,i,:) = t_av * dims(:,i);
        end
    end

end

