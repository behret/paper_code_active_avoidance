function [trans_data] = prepare_data_task_decoding_iti(p, traces, evs, bvs, tis, speed_control)


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

   
    %% get transition data
     [ trans_collection,trans_collection_pe,trans_types,trans_spds,pe_spds ] = ...
         collect_transition_data_per_ses(p, traces, evs, bvs, tis,speed_control);
    
    % for every session take the fastet n transitions of the task-relevant
    % type
    trans_data = {};
    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            if ~isempty(trans_collection{sub,ses})
                % collect ITI shuttles for decoding (n fastest) and DR (rest)
                [~,sortIdx] = sort(trans_spds{sub,ses},'descend');

                if ses<6
                    ttype = 0;
                else
                    ttype = 1;
                end

                wrong_type = trans_types{sub,ses}(sortIdx) ~= ttype;
                sortIdx(wrong_type) = [];

                this_n_trans = length(sortIdx);
                this_n_trans_dc = min(p.n_iti_trans,this_n_trans);

                trans_data{sub,ses} = trans_collection{sub,ses}(:,:,sortIdx(1:this_n_trans_dc));
            end
        end
    end
    
    
end

