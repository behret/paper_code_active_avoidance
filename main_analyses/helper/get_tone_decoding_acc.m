function [acc,weights] = get_tone_decoding_acc(tone_pool, n_tr, n_rep)
    

    %% decode tone vs iti for all tone time steps individually
    acc = [];
    weights = [];
    for rep = 1:n_rep
        % run decoding for all times steps
        for t = 1:size(tone_pool,2)
            
            % for tone sample trials for specific time point
            % for bl sample trial and time point
            rand_idx = randperm(size(tone_pool,3));
            tone_tr = rand_idx(1:n_tr);
            bl_tr_pre = rand_idx(n_tr+1:2*n_tr);

            tone_samples = [];
            bl_samples = [];
            for i = 1:n_tr
                % take time point t for tone
                this_tone_sample = tone_pool(:,t,tone_tr(i));
                tone_samples = cat(2,tone_samples,this_tone_sample);
                
                % take random t for pre tone
                rand_time = randi(4);
                this_bl_sample = tone_pool(:,rand_time,bl_tr_pre(i));
                bl_samples = cat(2,bl_samples,this_bl_sample);
            end

            % fit models
            x_train = cat(1,tone_samples',bl_samples');
            t_train = cat(1,ones(n_tr,1),zeros(n_tr,1));
            % train cv model and get accs
            Mdl_cv = fitcsvm(x_train,t_train, 'KernelFunction','linear', ...
                'kFold',5, 'Standardize',true); 
            acc(rep,t) = 1-kfoldLoss(Mdl_cv);
            
            % single model for weight analyis
            Mdl = fitcsvm(x_train,t_train, 'KernelFunction','linear', ...
                'Standardize',true); 
            
            % extract linear weights from model
            weights(rep,t,:) = Mdl.Beta;
        end
    end

end


