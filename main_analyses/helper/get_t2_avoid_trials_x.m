function [ av_x,av_no_x ] = get_t2_avoid_trials_x(p, traces, evs, bvs, tis, speed_control)


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
    [ av_x,av_no_x ] = collect_t2_av_trials_x(p, traces, bvs, tis, speed_control);
end

