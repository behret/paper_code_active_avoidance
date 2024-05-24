function [ t_pool] = prepare_data_tone_decoding(p, traces, evs, bvs, tis)
% prepare data for tone decoding
% - here we align trials to tone end (we exclude avoid trials with early
% shutoffs)
% - we dont differentiate between avoid and error 
% - we directly pool over sessions

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

    %% collect trials
    
    pre_steps = 5;
    post_steps = 25;
    t_pool = {};
    for sub = 1:p.nSubjects
        t_pool{sub} = [];
        for ses = 1:p.nSessions
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            for tr = 1:size(tis{sub,ses},2)
                lat = tis{sub,ses}(6,tr);
                if lat < post_steps & lat > 0
                    continue
                end
                % collect tone start
                alignment_point = tis{sub,ses}(1,tr);  
                win = alignment_point-pre_steps : alignment_point+post_steps-1;
                this_tone_start = traces{sub,ses}(:,win);
                t_pool{sub} = cat(3,t_pool{sub},this_tone_start);
            end
        end
    end
end

