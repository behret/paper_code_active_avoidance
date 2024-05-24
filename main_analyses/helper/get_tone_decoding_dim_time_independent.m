function [acc,tone_dim] = get_tone_decoding_dim_time_independent(tone_pool, n_tr, n_rep)
    
    %% decode tone vs iti (time independent)
    acc = [];
    weights = {};
    for rep = 1:n_rep
        % for tone sample trials for specific time point
        % for bl sample trial and time point
        rand_idx = randperm(size(tone_pool,3));
        tone_tr = rand_idx(1:n_tr);
        bl_tr_pre = rand_idx(n_tr+1:2*n_tr);
        
        tone_samples = [];
        bl_samples = [];
        for i = 1:n_tr
            % for tone we have to cut the 5 time steps before tone start
            % and after tone end -> sample 1 to 25 and do +5            
            rand_time = randi(25);
            this_tone_sample = tone_pool(:,5+rand_time,tone_tr(i));
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
        acc(rep) = 1-kfoldLoss(Mdl_cv);
        % single model for weight analyis
        Mdl = fitcsvm(x_train,t_train, 'KernelFunction','linear', ...
            'Standardize',true); 

        % extract linear weights from model
        weights{rep} = Mdl.Beta;
    end

    %%
    weight_cat = cat(2,weights{:});
    tone_dim = mean(weight_cat,2);
    tone_dim = tone_dim/norm(tone_dim);
end


