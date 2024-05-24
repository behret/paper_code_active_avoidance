function [ t_pool ] = project_trial_set_into_one_subspace(p,trials,trial_idx,q)


    %% project trials into subspace
    
    % project trials into joint subspace
    t_pool = [];
    for sub = 1:p.nSubjects
        % project avoidance trials
        if isempty(trial_idx)
            if ~isempty(trials{sub})
                trial_list = 1:size(trials{sub},3); % take all trials if trials idx is empty
            else
                trial_list = [];
            end
        else
            trial_list = trial_idx{sub};
        end
        for tr = trial_list
            this_tr = trials{sub}(:,:,tr);
            this_proj = this_tr' * q{sub};
            t_pool = cat(3,t_pool,this_proj');
        end
    end

end

