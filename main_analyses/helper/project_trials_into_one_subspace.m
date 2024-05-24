function [ av_trials, err_trials, trans_data ] = project_trials_into_one_subspace(p,av_trials,err_trials,trans_data,trial_idx,q,cell_means,dr_dc)


    %% project DC trials into subspace and pool over tasks
    
    % project trials into joint subspace
    t_pool_av = [];
    t_pool_err = [];
    t_pool_trans = [];
    for sub = 1:p.nSubjects
        % project avoidance trials
        for tr = trial_idx{sub,1,dr_dc}
            this_tr = av_trials{sub}(:,:,tr);
            this_tr = this_tr-cell_means{sub};
            this_proj = this_tr' * q{sub};
            t_pool_av = cat(3,t_pool_av,this_proj');
        end

        % project err trials
        for tr = trial_idx{sub,2,dr_dc}
            this_tr = err_trials{sub}(:,:,tr);
            this_tr = this_tr-cell_means{sub};
            this_proj = this_tr' * q{sub};
            t_pool_err = cat(3,t_pool_err,this_proj');
        end

        % project transitions
        for tr = trial_idx{sub,3,dr_dc}
            this_tr = trans_data{sub}(:,:,tr);
            this_tr = this_tr-cell_means{sub};
            this_proj = this_tr' * q{sub};
            t_pool_trans = cat(3,t_pool_trans,this_proj');
        end
    end
    
    av_trials = t_pool_av;
    err_trials = t_pool_err;
    trans_data = t_pool_trans;

end

