function [ av_trials,err_trials,trans_data,trans_data_err,err_trials_full,trans_data_dr,tone_idx] = prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control)


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

    %% prepare trial data
    % get data for tone end
    tone_start_control = 0; 
    [ av_trials_end,err_trials_end,tone_idx ] = collect_ae_trials_all_ses(p, traces, evs, bvs, tis, speed_control,tone_start_control);

    tone_start_control = 1; 
    [ av_trials_start,err_trials_start,~ ] = collect_ae_trials_all_ses(p, traces, evs, bvs, tis,speed_control,tone_start_control);
    
    % concat trial start and trial end
    av_trials = {};
    err_trials = {};
    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            av_trials{sub,ses} = cat(2,av_trials_start{sub,ses},av_trials_end{sub,ses});
            err_trials{sub,ses} = cat(2,err_trials_start{sub,ses},err_trials_end{sub,ses});
        end
    end
    
    %% get transition data
     [ trans_collection,trans_collection_pe,trans_types,trans_spds,pe_spds ] = ...
         collect_transition_data_per_ses(p, traces, evs, bvs, tis,speed_control);

    % here we chose how to separate ITI data into DR and decoding
    trans_data = {};
    trans_data_err = {};
    trans_data_dr = {};
    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            % collect ITI shuttles for decoding (n fastest) and DR (rest)
            [~,sortIdx] = sort(trans_spds{sub,ses},'descend');
            this_n_trans = size(trans_collection{sub,ses},3);
            this_n_trans_dc = min(p.n_iti_trans,this_n_trans);
                        
            if ~isempty(trans_collection{sub,ses})
                trans_data{sub,ses} = trans_collection{sub,ses}(:,:,sortIdx(1:this_n_trans_dc));
                trans_data_dr{sub,ses} = trans_collection{sub,ses}(:,:,sortIdx(this_n_trans_dc+1:end));
            end
            
            % collect ITI pseudo errors (n fastest)
            if ~isempty(trans_collection_pe{sub,ses})
                [~,sortIdx] = sort(pe_spds{sub,ses},'descend');
                trans_data_err{sub,ses} = trans_collection_pe{sub,ses}(:,:,sortIdx(2:end));
            end
        end
    end
    
    %% get full error trials
    [err_trials_full] = collect_full_error_trials_per_ses(p, traces, bvs, tis,speed_control);
end

