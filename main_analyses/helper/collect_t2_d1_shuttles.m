function [ shuttle_trials,no_shuttle_trials,action_start_times,trial_nums,trial_spds ] = collect_t2_d1_shuttles(p, traces, bvs, tis, speed_control,action_aligned)

    spd_dims = 18:22; %dlc
    if action_aligned
        pre_steps = 15;
        post_steps = 5;
    else
        pre_steps = 25;
        post_steps = 75;
    end
    
    trial_nums = cell(p.nSubjects,2); % record the number of each trial so we can correlate it with activity
    trial_spds = cell(p.nSubjects,2); % record the speed of each trial so we can correlate it with activity
    for sub = 1:p.nSubjects
        % first collect all av trials and keep track of the action
        % start times that were used.
        % then collect error trials and sample alignment points
        action_start_times{sub} = [];
        shuttle_trials{sub} = [];
        no_shuttle_trials{sub} = [];
        for ses = 5:6
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            % for getting action start
            spd_diff = diff([bvs{sub,ses}(23,:) 0]);
            for tr = 1:size(tis{sub,ses},2)
                if tis{sub,ses}(3,tr) ~= 0 
                    tr_win = tis{sub,ses}(1,tr):tis{sub,ses}(1,tr)+50-1;
                    d1_shuttle = find(abs(diff(bvs{sub,ses}(5,tr_win))) == 2,1,'first');
                    if ~isempty(d1_shuttle)
                        shuttle_abs = tis{sub,ses}(1,tr) + d1_shuttle;
                        this_win = shuttle_abs-10:shuttle_abs;
                        [~,max_diff_idx] = max(spd_diff(this_win));
                        dt_start = 11-max_diff_idx;
                        rel_start =  d1_shuttle-dt_start+1;
                        if action_aligned
                            if rel_start < pre_steps
                                continue
                            end
                            alignment_point = tis{sub,ses}(1,tr) + rel_start;
                        else
                            alignment_point = tis{sub,ses}(1,tr);
                        end
                        win = alignment_point-pre_steps : alignment_point+post_steps-1;
                        this_data = traces{sub,ses}(:,win);
                        if speed_control
                            this_data = bvs{sub,ses}(spd_dims,win);
                        end
                        shuttle_trials{sub} = cat(3,shuttle_trials{sub},this_data);       
                        % collect action start time
                        action_start_times{sub} = [action_start_times{sub} rel_start];
                        % collect trial number and speed
                        trial_nums{sub,1} = cat(1,trial_nums{sub,1},tr+(ses-5)*50);       
                        trial_spds{sub,1} = cat(1,trial_spds{sub,1},mean(bvs{sub,ses}(23,win)));       
                    else
                        % collect error trials without d1 shuttle as
                        % control
                        alignment_point = tis{sub,ses}(1,tr);
                        win = alignment_point-pre_steps : alignment_point+post_steps-1;
                        this_data = traces{sub,ses}(:,win);
                        if speed_control
                            this_data = bvs{sub,ses}(spd_dims,win);
                        end
                        no_shuttle_trials{sub} = cat(3,no_shuttle_trials{sub},this_data);       
                        
                        trial_nums{sub,2} = cat(1,trial_nums{sub,2},tr+(ses-5)*50);       
                        trial_spds{sub,2} = cat(1,trial_spds{sub,2},mean(bvs{sub,ses}(23,tis{sub,ses}(1,tr):tis{sub,ses}(1,tr)+49)));  
                    end
                end
            end
        end
    end
end

