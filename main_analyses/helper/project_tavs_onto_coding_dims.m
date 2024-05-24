function [proj_a,proj_e,ve,d_primes] = project_tavs_onto_coding_dims(dims,av_trials,err_trials)
    
    n_dims = size(dims,2);

    % concat a and e trial averages to build coding space
    t_avs_a = nanmean(av_trials,3);
    t_avs_e = nanmean(err_trials,3);    
    y_ld = cat(2,t_avs_a,t_avs_e)';
    y_ld = y_ld - mean(y_ld);
    
    
    %% project t_avs into defined dims, calc VE 
    proj_a = [];
    proj_e = [];
    ve = [];
    for nd = 1:n_dims
        proj_a(:,nd) = t_avs_a'*dims(:,nd);
        proj_e(:,nd) = t_avs_e'*dims(:,nd);

        % calculate VE
        org = y_ld;
        rec = y_ld*dims(:,nd)*dims(:,nd)';
        ve(nd) = 100*(1 - norm(org-rec,'fro')^2  / norm(org,'fro')^2);
    end

    %% calc d-primes
    
    d_primes = [];
    % project all trials
    for d = 1:size(dims,2)
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
        d_primes(:,d) = mn_diff./joint_sd;
    end
    
end

