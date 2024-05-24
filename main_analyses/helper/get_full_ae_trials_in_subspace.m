function [av_trials,err_trials,iti_trials,iti_err_trials] = ...
    get_full_ae_trials_in_subspace(p, av_trials_all,err_trials_all,iti_trials_all,iti_err_trials_all,q,trial_idx_ses,sessions)

    %% collect A/E data
    
    av_trials_cat = {};
    err_trials_cat = {};
    
    for sub = 1:p.nSubjects
        av_trials_cat{sub} = [];
        err_trials_cat{sub} = [];
        iti_trials_cat{sub} = [];
        iti_err_trials_cat{sub} = [];
        for ses = sessions
            av_trials_cat{sub} = cat(3,av_trials_cat{sub},av_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,1,2}));
            if ~isempty(err_trials_all{sub,ses})
                err_trials_cat{sub} = cat(3,err_trials_cat{sub},err_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,2,2}));
            end
            iti_trials_cat{sub} = cat(3,iti_trials_cat{sub},iti_trials_all{sub,ses}); % no trial selection necessary
            iti_err_trials_cat{sub} = cat(3,iti_err_trials_cat{sub},iti_err_trials_all{sub,ses}); % no trial selection necessary
        end
    end
  
    %% do DR and concat for all
    av_trials = project_trial_set_into_one_subspace(p,av_trials_cat,[],q);
    err_trials = project_trial_set_into_one_subspace(p,err_trials_cat,[],q);
    iti_trials = project_trial_set_into_one_subspace(p,iti_trials_cat,[],q);
    iti_err_trials = project_trial_set_into_one_subspace(p,iti_err_trials_cat,[],q);
end