function [eval_accs] = eval_time_independent_decoder_per_timestep(t_pool_tone,n_rep,n_tr,nullspace)


    %% project data into motion / avoid nullspace
    tone_null = [];
    for t = 1:size(t_pool_tone,2) % loop over time
        tone_null(:,t,:) = nullspace' * squeeze(t_pool_tone(:,t,:));
    end
    
    %%

    eval_accs = [];
    for rep = 1:n_rep
        % for tone sample trials for specific time point
        rand_idx = randperm(size(tone_null,3));
        tone_tr = rand_idx(1:n_tr);
        tone_tr_test = rand_idx(n_tr+1:n_tr*2);
        bl_tr_pre = rand_idx(2*n_tr+1:3*n_tr);
        bl_tr_pre_test = rand_idx(3*n_tr+1:4*n_tr);

        tone_samples = [];
        bl_samples = [];
        for i = 1:n_tr
            % for tone we have to cut the 5 time steps before tone start
            % and after tone end -> sample 1 to 30 and do +5            
            rand_time = randi(25);
            this_tone_sample = tone_null(:,5+rand_time,tone_tr(i));
            tone_samples = cat(2,tone_samples,this_tone_sample);
            
            % take random t for pre tone
            rand_time = randi(4);
            this_bl_sample = tone_null(:,rand_time,bl_tr_pre(i));
            bl_samples = cat(2,bl_samples,this_bl_sample);
        end

        % fit models
        x_train = cat(1,tone_samples',bl_samples');
        t_train = cat(1,ones(n_tr,1),zeros(n_tr,1));

        % train single model
        Mdl = fitcsvm(x_train,t_train, 'KernelFunction','linear', ...
            'Standardize',true); 

        % test for every time step in test trials
        preds = [];
        for tr = 1:n_tr
            for i = 1:size(tone_null,2)
                preds(tr,i,1) = predict(Mdl,tone_null(:,i,tone_tr_test(tr))');
                rand_time = randi(4);
                preds(tr,i,2) = 1-predict(Mdl,tone_null(:,rand_time,bl_tr_pre_test(tr))');
            end
        end
        eval_accs(rep,:) = squeeze(mean(mean(preds),3));
    end
end
