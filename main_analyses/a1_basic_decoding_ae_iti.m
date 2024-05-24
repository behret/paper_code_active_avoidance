% do basic decoding for 4 different settings:
% neural vs. speed
% a/e vs. iti

clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%%
fpath = fullfile(p.data_dir,'basic_ae_with_spd_and_iti_control');
saveData = 1;
saveFigs = 1;
n_rep = 80;
n_dc_rep = 2;
aa_sessions = 3:9;
n_pc = 10;

% here we need to equalize between avoid/error iti/iti_error
% minimum setting is for iti avoid, which is around 350
n_tr = 300;

%
all_acc = [];
for rep = 1:n_rep
    tic
    for i = 1:8
        if i == 1 % neural decoders for a/e
            speed_control = 0;
            iti_control = 0;
            shuffle_control = 0;
        elseif i == 2 % neural decoders for iti
            speed_control = 0;
            iti_control = 1;
            shuffle_control = 0;
        elseif i == 3 % speed decoders for a/e
            speed_control = 1;
            iti_control = 0;
            shuffle_control = 0;
        elseif i == 4 % speed decoders for iti
            speed_control = 1;
            iti_control = 1;
            shuffle_control = 0;
        elseif i == 5
            speed_control = 0;
            iti_control = 0;
            shuffle_control = 1;
        elseif i == 6
            speed_control = 0;
            iti_control = 1;
            shuffle_control = 1;
        elseif i == 7
            speed_control = 1;
            iti_control = 0;
            shuffle_control = 1;
        elseif i == 8
            speed_control = 1;
            iti_control = 1;
            shuffle_control = 1;
        end

        %% run DR and decoding procedure for different trial samples
        [av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
            prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);

        
        if speed_control == 0
            % do DR
            [q, trial_idx_ses, ~, ~, ~, ~] = dr_into_joint_subspace(p, av_trials_all, err_trials_all, trans_data_all_dr, n_pc);
            % project and concat trials
            [av_trials, err_trials, av_trials_iti, err_trials_iti, av_trials_dr, err_trials_dr, trans_data_dr, tone_idx] = ...
                organize_trials_ae_iti(p, av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, q, trial_idx_ses,...
                aa_sessions, trans_data_all_dr, tone_idx);
            
            if iti_control
                av_trials = av_trials_iti;
                err_trials = err_trials_iti;
            end
        else
            if iti_control
                av_data = trans_data_all;
                err_data = trans_data_err_all;
            else
                av_data = av_trials_all;
                err_data = err_trials_all;
            end
            % concat data from different sessions and subjects
            av_trials = [];
            err_trials = [];
            tone_idx_cat = [];
            for sub = 1:p.nSubjects    
                av_trials = cat(3,av_trials,av_data{sub,aa_sessions});
                err_trials = cat(3,err_trials,err_data{sub,aa_sessions});
                tone_idx_cat = cat(1,tone_idx_cat,tone_idx{sub,aa_sessions});
            end
            tone_idx = tone_idx_cat;
            % CUT TIME (different for ae and iti)
            if iti_control
                av_trials = av_trials(:,6:25,:);
                err_trials = err_trials(:,6:25,:);
            else 
                av_trials = av_trials(:,21:40,:);
                err_trials = err_trials(:,21:40,:);
            end
        end
        %%
        if iti_control
            tone_idx = [];
        end
        [ all_acc(rep,i,:,:),~ ] = get_ae_decoding_dim( p,av_trials,err_trials,n_dc_rep,n_tr,shuffle_control, tone_idx);
    end
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

%%
if saveData
    save(fpath,'all_acc')
end

%% 

plots_a1;