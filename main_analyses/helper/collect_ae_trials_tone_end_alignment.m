function [ av_trials,err_trials ] = collect_ae_trials_tone_end_alignment(p, traces, bvs, tis, speed_control,tone_start_control)

    spd_dims = 18:22; %dlc
    pre_steps = 15;
    post_steps = 5;
   
    for sub = 1:p.nSubjects
        % first collect all av trials and keep track of the action
        % start times that were used.
        % then collect error trials and sample alignment points
        action_start_times = [];
        for ses = 1:p.nSessions
            av_trials{sub,ses} = [];
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            for tr = 1:size(tis{sub,ses},2)
                if tis{sub,ses}(3,tr) == 0 
                    % avoid trials
                    alignment_point = tis{sub,ses}(1,tr) + tis{sub,ses}(6,tr); 
                    win = alignment_point-pre_steps : alignment_point+post_steps-1;
                    this_data = traces{sub,ses}(:,win);
                    if speed_control
                        this_data = bvs{sub,ses}(spd_dims,win);
                    end
                    av_trials{sub,ses} = cat(3,av_trials{sub,ses},this_data);       
                end
            end
        end

        % now collect error trials and sample from the avoid time
        % distribution (only of the trials used here!)
        for ses = 1:p.nSessions
            err_trials{sub,ses} = [];
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            for tr = 1:size(tis{sub,ses},2)
                if tis{sub,ses}(3,tr) > 0 
                    % error trials
                    alignment_point = tis{sub,ses}(1,tr) + 50-1;
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

