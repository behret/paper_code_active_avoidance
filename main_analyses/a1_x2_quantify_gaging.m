% info content similarity: the difference of av-err and iti-rand deocidng

% what we want to equalize is info content between av-err and iti-rand 
% -> only measure those two 
% -> quantify gaging with info content and use av-iti to demonstrate
% that the result of the gaging procedure gives low accs 

%%
clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%%
fpath = fullfile(p.data_dir,'iti_gaging_analysis');
saveData = 1;
saveFigs = 1;
n_rep = 80;
n_dc_rep = 2;
aa_sessions = 3:9;

% here we need to equalize between avoid/error iti/iti_error
% minimum setting is for iti avoid, which is around 350
n_tr = 300;
shuffle_control = 0;
speed_control = 1;

gaging_var = [30 25 20 15 10 5];
all_acc = [];
mn_spd_trials = {};
mn_spd_time = {};
for rep = 1:n_rep
    tic
    for g = 1:length(gaging_var)
        for i = 1:2

            %% 
            p.n_iti_trans = gaging_var(g);
            [av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
                prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);
            
            av_data = av_trials_all;
            err_data = err_trials_all;
            iti_data = trans_data_all;
            rand_data = trans_data_err_all;   

            % concat data from different sessions and subjects
            av_trials = [];
            av_trials_iti = [];
            err_trials = [];
            err_trials_iti = [];

            for sub = 1:p.nSubjects    
                av_trials = cat(3,av_trials,av_data{sub,aa_sessions});
                av_trials_iti = cat(3,av_trials_iti,iti_data{sub,aa_sessions});
                err_trials = cat(3,err_trials,err_data{sub,aa_sessions});
                err_trials_iti = cat(3,err_trials_iti,rand_data{sub,aa_sessions});
            end
            % CUT TIME (different for av and iti)
            av_trials = av_trials(:,21:40,:);
            err_trials = err_trials(:,21:40,:);
            av_trials_iti = av_trials_iti(:,6:25,:);
            err_trials_iti = err_trials_iti(:,6:25,:);

            if i == 1 % av / err
                trialset1 = av_trials;
                trialset2 = err_trials;
            elseif i == 2 % iti/rand
                trialset1 = av_trials_iti;
                trialset2 = err_trials_iti;
            end

            %% calculate mean speed (over trials/over time)
            if rep == 1
                mn_spd_time{g,i} = squeeze(mean(mean(trialset1(:,11:20,:),1),2))*0.06; % convert to cm/s
                mn_spd_trials{g,i} = squeeze(mean(mean(trialset1,1),3))*0.06;
            end
            
            %% run decoding
            [ all_acc(rep,g,i,:,:),~ ] = get_ae_decoding_dim( p,trialset1,trialset2,n_dc_rep,n_tr,shuffle_control,[]);
        end
    end
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

%%
if saveData
    save(fpath,'all_acc','mn_spd_time','mn_spd_trials','gaging_var')
end
