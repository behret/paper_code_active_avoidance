function [av_x,av_no_x] = collect_t2_av_trials_x(p, traces, bvs, tis, speed_control)

    spd_dims = 18:22; %dlc
    pre_steps = 15;
    post_steps = 5;

    for sub = 1:p.nSubjects
        av_x{sub} = [];
        av_no_x{sub} = [];
        for ses = 5:9
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            % for getting action start
            spd_diff = diff([bvs{sub,ses}(23,:) 0]);
            for tr = 1:size(tis{sub,ses},2)
                if tis{sub,ses}(3,tr) == 0                     
                    shuttle_abs = tis{sub,ses}(1,tr) + tis{sub,ses}(6,tr);
                    this_win = shuttle_abs-10:shuttle_abs;
                    [~,max_diff_idx] = max(spd_diff(this_win));
                    dt_start = 11-max_diff_idx;
                    rel_start =  tis{sub,ses}(6,tr)-dt_start;
                    if rel_start < pre_steps
                        continue
                    end
                    alignment_point = tis{sub,ses}(1,tr) + rel_start;
                    win = alignment_point-pre_steps : alignment_point+post_steps-1;
                    this_data = traces{sub,ses}(:,win);
                    if speed_control
                        this_data = bvs{sub,ses}(spd_dims,win);
                    end

                    % assign to x or no_x: test if there was an
                    % x-shuttle in the window from trial start to trial
                    % end + 1s
                    start = tis{sub,ses}(1,tr);
                    stop = start+tis{sub,ses}(6,tr)-1;
                    qs = bvs{sub,ses}(5,start:stop);
                    if any(abs(qs - qs(1)) > 1)
                        av_x{sub} = cat(3,av_x{sub},this_data);      
                    else
                        av_no_x{sub} = cat(3,av_no_x{sub},this_data);      
                    end
                end
            end
        end
    end
end

