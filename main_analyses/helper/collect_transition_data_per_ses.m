function [ trans_collection,trans_collection_pe,trans_types,trans_spds,pe_spds ] = collect_transition_data_per_ses(p, traces, evs, bvs, tis, speed_control)

    % collect all ITI transitions (independent of direction and speed)
    % return shuttle direction and speed as additional output
    % use these outputs elsewhere to determine what to do with the ITI data
    
    spd_dims = 18:22; %dlc
    pre_steps_trans = 20;
    post_steps_trans = 20;

    % take the fastest for decoding and the rest for DR
    trans_collection = {};
    spd_collection = {};
    trans_types = {};
    trans_spds = {};

    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions 
            
            trans_collection{sub,ses} = [];
            spd_collection{sub,ses} = [];

            if any(ses == p.alignment.exclude{sub})
                continue
            end
            
            spd_diff = diff([bvs{sub,ses}(23,:) 0]);

            % find all transitions and save transition type
            q_diff = diff(bvs{sub,ses}(5,:));
            trans = find(q_diff ~= 0);
            % task 1 shuttle has a diff of 2, which will be mapped to a 0
            % task 2 shuttle has a diff of 1 which willb e mapped to a 1
            t_type = abs(q_diff(trans) == 1);

            % filter transitions during trials
            during = evs{sub,ses}(1,trans);
            trans = trans(~during);
            t_type = t_type(~during);
            
            % filter early and late transitions
            trans(trans > 11900) = [];
            trans(trans < 100) = [];
            t_type(trans > 11900) = [];
            t_type(trans < 100) = [];
            
            % filter transitions in quick succession (always take first one)
            pre_trans = [0 diff(trans)];
            trans = trans(pre_trans > 20);
            t_type = t_type(pre_trans > 20);

            t_spds = [];
            for i = 1:length(trans)
                t_spds(i) = mean(bvs{sub,ses}(23,trans(i)-2:trans(i)+2));
            end

            % sort according to speed and cut
            [~,sortIdx] = sort(t_spds,'descend');
            trans = trans(sortIdx(1:min(length(sortIdx),30)));
            t_type = t_type(sortIdx(1:min(length(sortIdx),30)));
            t_spds = t_spds(sortIdx(1:min(length(sortIdx),30)));
            
            % save type and spd
            trans_types{sub,ses} = t_type;
            trans_spds{sub,ses} = t_spds;
            
            % get cutouts 
            for tr = 1:size(trans,2)
                shuttle_abs = trans(tr);
                this_win = shuttle_abs-10:shuttle_abs;
                [~,max_diff_idx] = max(spd_diff(this_win));
                dt_start = 11-max_diff_idx;
                
                alignment_point = shuttle_abs-dt_start;
                win = alignment_point-pre_steps_trans : alignment_point+post_steps_trans-1;
                this_data = traces{sub,ses}(:,win);
                this_spd_data = bvs{sub,ses}(spd_dims,win);

                % save
                trans_collection{sub,ses}  = cat(3,trans_collection{sub,ses},this_data);       
                spd_collection{sub,ses} = cat(3,spd_collection{sub,ses},this_spd_data);     
            end
        end
    end

    %% add data for pseudo error trials
    
    trans_collection_pe = {};
    spd_collection_pe = {};
    pe_spds = {};
    
    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions 
            
            trans_collection_pe{sub,ses} = [];
            spd_collection_pe{sub,ses} = [];
            
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            
            trans = find(diff(bvs{sub,ses}(5,:)) ~= 0);
            
            % sample random time points and make sure they
            % - are not too early or too late in the session
            % - are not part of a trial
            % - do not overlap
            aps = [];
            win_spds = [];
            i = 0;
            while length(aps) < 30 && i < 10000
                i = i+1;
                rand_idx = randi(size(traces{sub,ses},2));
                
                % early / late
                if rand_idx < 100 || rand_idx > 11900
                    continue
                end
                
                win = rand_idx-pre_steps_trans : rand_idx+post_steps_trans-1;
                % during trial
                if any(evs{sub,ses}(1,win))
                    continue
                end
                
                % overlap
                if any(abs(aps - rand_idx) < length(win)) 
                    continue
                end
                
                aps = [aps rand_idx];
                this_win_spd = mean(bvs{sub,ses}(23,win));
                win_spds = [win_spds this_win_spd];
            end
            
            % save mean speed
            pe_spds{sub,ses} = win_spds;
            
            for tr = 1:size(aps,2)
                alignment_point = aps(tr);
                win = alignment_point-pre_steps_trans : alignment_point+post_steps_trans-1;
                this_data = traces{sub,ses}(:,win);
                this_spd_data = bvs{sub,ses}(spd_dims,win);

                % save
                trans_collection_pe{sub,ses}  = cat(3,trans_collection_pe{sub,ses},this_data);       
                spd_collection_pe{sub,ses} = cat(3,spd_collection_pe{sub,ses},this_spd_data);     
            end
        end
    end

    if speed_control
        trans_collection = spd_collection;
        trans_collection_pe = spd_collection_pe;
    end
    
    
end

