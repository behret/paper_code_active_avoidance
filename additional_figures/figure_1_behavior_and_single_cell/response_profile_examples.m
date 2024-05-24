
%% load data
clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'tis','bvs','traces','evs')
[cols,alpha] = chooseColors;
z_cutoff = 2;

%%
pad_pre = 25;
pad_post = 75;
profiles = {};
for sub = 1:11
    tone_avs = [];
    shuttle_avs = [];
    for ce = 1:size(traces{sub,1},1)
        % collect avoid trials
        trials_tone = [];
        trials_shuttle = [];
        shuttle_times = [];
        for ses = 3:9
            for tr = 1:50
                if tis{sub,ses}(3,tr) == 0
                    % get cutouts aligned to tone start
                    ap = tis{sub,ses}(1,tr);
                    win = ap - pad_pre: ap + pad_post-1;
                    this_tr = traces{sub,ses}(ce,win);
                    trials_tone = cat(1,trials_tone,this_tr);

                    % get cutouts aligned to shuttle start
                    ap = tis{sub,ses}(1,tr) + tis{sub,ses}(12,tr);
                    win = ap - pad_post: ap + pad_pre-1;
                    this_tr = traces{sub,ses}(ce,win);
                    trials_shuttle = cat(1,trials_shuttle,this_tr);

                    shuttle_times = cat(1,shuttle_times,tis{sub,ses}(12,tr));
                end
            end
        end

        % calculate trial average with all trials that are long enough 
        % (shuttle start after 3s)
        fil = shuttle_times > 15;
        win = 21:40;
        t_av_tone = nanmean(trials_tone(fil,win));
        tone_avs = cat(1,tone_avs,t_av_tone);

        win = 61:80;
        t_av_shuttle = nanmean(trials_shuttle(fil,win));
        shuttle_avs = cat(1,shuttle_avs,t_av_shuttle);
    end
    
    sep = zeros(size(tone_avs,1),5)/0;
    profiles{sub} = [tone_avs sep shuttle_avs];
end


%% plot profiles of some example cells

% reuse colors from removal analysis
this_cols = {};
this_cmap = spring;
this_cols{1} = this_cmap(30,:);
this_cols{2} = this_cmap(50,:);
this_cmap = winter;
this_cols{3} = this_cmap(25,:);
this_cols{4} = this_cmap(60,:);

for sub = 1%:11
    
    lims = [-1 4];
    figure('Position',[100 100 300 300],'Renderer','painters')

    [~,sortIdx] = sort(nanvar(profiles{sub}'),'descend');
    hold on
    count = 1;
    for i = [2 3 4 6]
        plot(profiles{sub}(sortIdx(i),:),'LineWidth',2,'Color',this_cols{count})
        count = count+1;
    end
    
    ylim(lims)
    xlim([0 46])
    set(gca,'XTick',[5 20 25 40]) 
    set(gca,'XTickLabel',[0 3 -3 0])
    xlabel('time (s)')
    ylabel('\DeltaF/F (%)')
    plot([5,5],lims,'Color',[.7 .7 .7])
    plot([40,40],lims,'Color',[.7 .7 .7])
end

fpath = fullfile(p.out_dir,'fig1','example_response_profiles.svg');
saveas(gca,fpath,'svg')
