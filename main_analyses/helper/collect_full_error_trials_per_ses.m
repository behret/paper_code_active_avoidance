function [ err_trials ] = collect_full_error_trials_per_ses(p, traces, bvs, tis,speed_control)

    spd_dims = 18:22; %dlc
    pre_steps = 5;
    post_steps = 50+20;
   
    for sub = 1:p.nSubjects
        % collect error trials 
        for ses = 1:p.nSessions
            err_trials{sub,ses} = [];
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            for tr = 1:size(tis{sub,ses},2)
                if tis{sub,ses}(3,tr) > 0 
                    alignment_point = tis{sub,ses}(1,tr);  
                    win = alignment_point-pre_steps : alignment_point+post_steps-1;
                    this_data = traces{sub,ses}(:,win);
                    if speed_control
                        this_data = bvs{sub,ses}(spd_dims,win);
                    end
                    err_trials{sub,ses} = cat(3,err_trials{sub,ses},this_data);    
                end
            end
        end
    end
end

