function [ shuttles,no_shuttles, shuttle_times,trial_nums,trial_spds ] = get_t2_d1_shuttles(p, traces, evs, bvs, tis, speed_control,action_aligned)


    %% calc scale factors per subject
    for sub = 1:p.nSubjects
        all_tr = cat(2,traces{sub,:});
        vars(sub) = nanstd(all_tr(:));
    end
    scale_factors = 1./(vars / max(vars));

    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            traces{sub,ses} = traces{sub,ses}.*scale_factors(sub);
        end
    end

    %% prepare data trial data
    % get data for tone end
    [ shuttles,no_shuttles,shuttle_times,trial_nums,trial_spds ] = collect_t2_d1_shuttles(p, traces, bvs, tis, speed_control,action_aligned);
end

