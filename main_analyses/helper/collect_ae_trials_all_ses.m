function [ av_trials,err_trials,tone_idx ] = collect_ae_trials_all_ses(p, traces, evs, bvs, tis, speed_control,tone_start_control)

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
            % record when the tone was off to exclude some trials for specific time steps in later analyses
            tone_idx{sub,ses} = []; 
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            
            % for getting action start
            spd_diff = diff([bvs{sub,ses}(23,:) 0]);
            
            for tr = 1:size(tis{sub,ses},2)
                if tis{sub,ses}(3,tr) == 0 
                    % first find action start (not done for ext sessions in
                    % collcet_all_data...)
                    shuttle_abs = tis{sub,ses}(1,tr) + tis{sub,ses}(6,tr);
                    this_win = shuttle_abs-10:shuttle_abs;
                    [~,max_diff_idx] = max(spd_diff(this_win));
                    dt_start = 11-max_diff_idx;
                    rel_start =  tis{sub,ses}(6,tr)-dt_start;
                    % exclude trials where pre action period is not long enough
                    if rel_start < pre_steps
                        continue
                    end
                    
                    % avoid trials
                    alignment_point = tis{sub,ses}(1,tr) + rel_start;
                    if tone_start_control
                        % shift to account for pre_steps which is subtracted below. 
                        % keep 5 time steps before tone start
                        alignment_point = tis{sub,ses}(1,tr) + (pre_steps-5); 
                    end   
                    win = alignment_point-pre_steps : alignment_point+post_steps-1;
                    this_data = traces{sub,ses}(:,win);
                    if speed_control
                        this_data = bvs{sub,ses}(spd_dims,win);
                    end
                    av_trials{sub,ses} = cat(3,av_trials{sub,ses},this_data);       
                    
                    
                    this_tone_idx = evs{sub,ses}(5,win);
                    tone_idx{sub,ses} = cat(1,tone_idx{sub,ses},this_tone_idx);
                    % collect action start time
                    action_start_times = [action_start_times rel_start];
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
                    % exclude T2 error trials with an x-shuttle
                    tr_win = tis{sub,ses}(1,tr):tis{sub,ses}(1,tr)+50-1;
                    x_shuttle = find(abs(diff(bvs{sub,ses}(5,tr_win))) == 2,1,'first');
                    y_shuttle = find(abs(diff(bvs{sub,ses}(5,tr_win))) == 1,1,'first');
                    t2_x_shuttle = ses > 4 & ~isempty(x_shuttle);
                    t1_y_shuttle = ses <= 4 & ~isempty(y_shuttle);
                    if t1_y_shuttle || t2_x_shuttle
                        continue
                    end
                    % error trials
                    % sample alignment point
                    randIdx = randi(length(action_start_times));
                    alignment_point = tis{sub,ses}(1,tr) + action_start_times(randIdx);
                    if tone_start_control
                        % shift to account for pre_steps which is subtracted below. 
                        % keep 5 time steps before tone start
                        alignment_point = tis{sub,ses}(1,tr) + (pre_steps-5); 
                    end   
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

