function [ av_trials,err_trials ] = collect_ae_trials_for_tone_analysis(p, traces, bvs, tis, speed_control,alignment_type)

    %alignment_types: 
    % 1: tone start 
    % 2: action start 
    % 3: tone end 
    

    spd_dims = 18:22; %dlc
    pre_steps = 15;
    post_steps = 15;
   
    for sub = 1:p.nSubjects
        % first collect all av trials and keep track of the action
        % start times that were used.
        % then collect error trials and sample alignment points
        action_start_times = [];
        for ses = 1:p.nSessions
            spd_diff = diff([bvs{sub,ses}(23,:) 0]);
            av_trials{sub,ses} = [];
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            for tr = 1:size(tis{sub,ses},2)
                if tis{sub,ses}(3,tr) == 0 
                    
                    % figure out action start
                    shuttle_abs = tis{sub,ses}(1,tr) + tis{sub,ses}(6,tr);
                    this_win = shuttle_abs-10:shuttle_abs;
                    [~,max_diff_idx] = max(spd_diff(this_win));
                    dt_start = 11-max_diff_idx;
                    rel_start =  tis{sub,ses}(6,tr)-dt_start;
                    % exclude trials where pre action period is not long enough
                    if rel_start < pre_steps
                        continue
                    end
                    
                    % define alignment point
                    if alignment_type == 1
                        alignment_point = tis{sub,ses}(1,tr);
                    elseif alignment_type == 2
                        alignment_point = tis{sub,ses}(1,tr) + rel_start;
                    elseif alignment_type == 3
                        alignment_point = tis{sub,ses}(1,tr) + tis{sub,ses}(6,tr);
                    end
                        
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

