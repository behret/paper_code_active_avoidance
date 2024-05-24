clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;
speed_control = 0;
saveFigs = 1;

this_ses = 7;
%%

[av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
    prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);



%% cat av trials for all cells
t_av_av = {};
for sub = 1:p.nSubjects
    t_av_av{sub} = squeeze(nanmean(cat(3,av_trials_all{sub,this_ses}),3));     
end

profiles = cat(1,t_av_av{:});

%% quantify z-scores per window

% first get all avoid trials including pre pad to match z-score calc from
% fig 1

pad_pre = 30;
tr_win = 15;
bl_avs = {};
tone = {};
pre = {};
post = {};
for sub = 1:p.nSubjects
    trials_bl = [];
    trials_tone = [];
    trials_shuttle = [];
    trials_post = [];
    for ses = this_ses
        for tr = 1:50
            % collect all trials that are longer than 15
            tr_len = tis{sub,ses}(12,tr);

            if tis{sub,ses}(3,tr) == 0 && tis{sub,ses}(12,tr) > 15
                
                % get before tone start
                ap = tis{sub,ses}(1,tr);
                win = ap - pad_pre: ap-1;
                this_tr = traces{sub,ses}(:,win);
                trials_bl = cat(3,trials_bl,this_tr); 
                
                % get cutouts aligned to tone start
                ap = tis{sub,ses}(1,tr);
                win = ap : ap + tr_win-1;
                this_tr = traces{sub,ses}(:,win);
                trials_tone = cat(3,trials_tone,this_tr);

                % get cutouts aligned to shuttle start
                ap = tis{sub,ses}(1,tr) + tis{sub,ses}(12,tr);
                win = ap - tr_win: ap - 1;
                this_tr = traces{sub,ses}(:,win);
                trials_shuttle = cat(3,trials_shuttle,this_tr);
                
                % get cutouts post shuttle start
                win = ap : ap + 4;
                this_tr = traces{sub,ses}(:,win);
                trials_post = cat(3,trials_post,this_tr);
            end
        end
    end
    % calc trial average
    bl_avs{sub} = nanmean(trials_bl,3);
    tone{sub} = nanmean(trials_tone,3);
    pre{sub} = nanmean(trials_shuttle,3);
    post{sub} = nanmean(trials_post,3);
end

bl_avs = cat(1,bl_avs{:});
tone = cat(1,tone{:});
pre = cat(1,pre{:});
post = cat(1,post{:});

bl_std = std(bl_avs,[],2);
bl_mean = mean(bl_avs,2);



%% plot z score
LB=flipud(lbmap(256,'BrownBlue'));
profiles_z = (profiles - bl_mean)./bl_std;

settings = {'tone_sorting','pre_shuttle_sorting','shuttle_sorting'};

for i = 1:3
    %sort_val = mean(profiles,2);          % all
    if i == 1
        sort_val = mean(profiles_z(:,6:20),2);  % tone
    elseif i == 2
        sort_val = mean(profiles_z(:,21:35),2); % avoid
    elseif i == 3
        sort_val = mean(profiles_z(:,35:40),2); % motion
    end
    [~,sortIdx] = sort(sort_val);

    figure('Position',[100 100 200 700])
    lims = [-20 20];
    imagesc(profiles_z(sortIdx,1:20),lims)
    set(gca,'XTick',[0.5 5 20])
    set(gca,'XTickLabel',[-1 0 3])
    colormap(LB)
    set(gca,'YTick',[1 size(profiles_z,1)])
    xlabel('Time (s)')
    ylabel('cells')
    
    
    if saveFigs
        fpath = fullfile(p.out_dir,'figS5',['tone_start_' settings{i} '.svg']);
        saveas(gca,fpath,'svg')
    end

    figure('Position',[100 100 200 700])
    lims = [-20 20];
    imagesc(profiles_z(sortIdx,21:40),lims)
    set(gca,'XTick',[0.5 15 20])
    set(gca,'XTickLabel',[-3 0 1])
    colormap(LB)
    set(gca,'YTick',[])
    xlabel('Time (s)')
    ax = colorbar;
    set(ax,'YTick',lims)
    
    if saveFigs
        fpath = fullfile(p.out_dir,'figS5',['action_start_' settings{i} '.svg']);
        saveas(gca,fpath,'svg')
    end


    
end

%% add indication of trial responsiveness


mean_z = mean(profiles_z(:,6:35),2);
trial_responsive = abs(mean_z) > 1.96;

for i = 1:3
    if i == 1
        sort_val = mean(profiles_z(:,6:20),2);  % tone
    elseif i == 2
        sort_val = mean(profiles_z(:,21:35),2); % avoid
    elseif i == 3
        sort_val = mean(profiles_z(:,35:40),2); % motion
    end
    [~,sortIdx] = sort(sort_val);

    figure('Position',[100 100 50 700])
    imagesc(~trial_responsive(sortIdx))
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    colormap gray    
    
    if saveFigs
        fpath = fullfile(p.out_dir,'figS5',['trial_resp_' settings{i} '.svg']);
        saveas(gca,fpath,'svg')
    end
end
