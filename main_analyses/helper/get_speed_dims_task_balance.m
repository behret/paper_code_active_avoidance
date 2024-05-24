function [ spd_dims ] = get_speed_dims_task_balance(p,trans_data_all,q)


    %% pool trials per task
    
    task_sessions{1} = 3:4;
    task_sessions{2} = 5:9;
    t_avs = {};
    t_pool = {};
    for t = 1:2
        t_pools = {};
        for sub = 1:p.nSubjects    
            t_pools{sub} = [];
            for ses = task_sessions{t}
                t_pools{sub} = cat(3,t_pools{sub},trans_data_all{sub,ses});
            end
        end
        t_pool{t} = project_trial_set_into_one_subspace(p,t_pools,[],q);
        t_avs{t} = squeeze(nanmean(t_pool{t},3));
    end

    %% run PCA
    
    y = squeeze(mean(cat(3,t_avs{:}),3));
    [coeff,score,latent,tsquared,explained,mu] = pca(y');
    spd_dims = coeff(:,1:5);

    % align signs
    for i = 1:5
        if score(25,i) < 0
            score(:,i) = -score(:,i);
            spd_dims(:,i) = -spd_dims(:,i);
        end
    end
    
    
end