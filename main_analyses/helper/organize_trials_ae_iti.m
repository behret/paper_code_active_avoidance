function [ av_trials, err_trials, av_trials_iti, err_trials_iti, av_trials_dr, err_trials_dr, trans_data_dr,tone_idx ] = ...
    organize_trials_ae_iti(p, av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,sessions,trans_data_all_dr,tone_idx)


    %% collect A/E data
    
    av_trials_cat = {};
    err_trials_cat = {};
    tone_idx_cat = {};
    
    for sub = 1:p.nSubjects
        av_trials_cat{sub} = [];
        err_trials_cat{sub} = [];
        tone_idx_cat{sub} = [];
        
        for ses = sessions
            if ~isempty(av_trials_all{sub,ses})
                av_trials_cat{sub} = cat(3,av_trials_cat{sub},av_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,1,2}));
            end
            if ~isempty(err_trials_all{sub,ses})
                err_trials_cat{sub} = cat(3,err_trials_cat{sub},err_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,2,2}));
            end
            if ~isempty(tone_idx{sub,ses})
                tone_idx_cat{sub} = cat(1,tone_idx_cat{sub},tone_idx{sub,ses}(trial_idx_ses{sub,ses,1,2},:));
            end
        end
    end
    
    %% collect ITI data
    
    av_trials_iti_cat = {};
    err_trials_iti_cat = {};

    for sub = 1:p.nSubjects
        av_trials_iti_cat{sub} = [];
        err_trials_iti_cat{sub} = [];
        for ses = sessions
            av_trials_iti_cat{sub} = cat(3,av_trials_iti_cat{sub},trans_data_all{sub,ses}); % take all since nothing was used for DR
            err_trials_iti_cat{sub} = cat(3,err_trials_iti_cat{sub},trans_data_err_all{sub,ses}); % take all since nothing was used for DR
        end
    end
    
    %% collect A/E/trans data for DR (for speed dims)
    av_trials_dr_cat = {};
    err_trials_dr_cat = {};
    trans_trials_dr_cat = {};
    for sub = 1:p.nSubjects
        av_trials_dr_cat{sub} = [];
        err_trials_dr_cat{sub} = [];
        trans_trials_dr_cat{sub} = [];

        for ses = sessions
            if ~isempty(av_trials_all{sub,ses})
                av_trials_dr_cat{sub} = cat(3,av_trials_dr_cat{sub},av_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,1,1}));
            end
            if ~isempty(err_trials_all{sub,ses})
                err_trials_dr_cat{sub} = cat(3,err_trials_dr_cat{sub},err_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,2,1})); 
            end
            if ~isempty(trans_data_all_dr{sub,ses})
                trans_trials_dr_cat{sub} = cat(3,trans_trials_dr_cat{sub},trans_data_all_dr{sub,ses}); % take all since nothing was used for DR
            end
        end
    end 
  
    %% do DR and concat for all
    av_trials = project_trial_set_into_one_subspace(p,av_trials_cat,[],q);
    err_trials = project_trial_set_into_one_subspace(p,err_trials_cat,[],q);
    av_trials_iti = project_trial_set_into_one_subspace(p,av_trials_iti_cat,[],q);
    err_trials_iti = project_trial_set_into_one_subspace(p,err_trials_iti_cat,[],q);
    av_trials_dr = project_trial_set_into_one_subspace(p,av_trials_dr_cat,[],q);
    err_trials_dr = project_trial_set_into_one_subspace(p,err_trials_dr_cat,[],q);
    trans_data_dr = project_trial_set_into_one_subspace(p,trans_trials_dr_cat,[],q);

    % concat tone_idx (same way as for av_trials)
    tone_idx = cat(1,tone_idx_cat{:});
    
    %% CUT TIME (different for ae and iti)
    av_trials = av_trials(:,21:40,:);
    err_trials = err_trials(:,21:40,:);
    av_trials_iti = av_trials_iti(:,6:25,:);
    err_trials_iti = err_trials_iti(:,6:25,:);

end