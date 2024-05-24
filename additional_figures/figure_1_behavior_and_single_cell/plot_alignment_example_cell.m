% - plot the activity of an example cell over trials for two alignments:
% tone start and action start
% - then plot the corresponding trials averages

%% load data
clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'tis','bvs','traces','evs')
[cols,alpha] = chooseColors;

%%
sub = 1;

for ce = 36
    pad_pre = 25;
    pad_post = 75;

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

    [~,sortIdx] = sort(shuttle_times,'ascend');

    figure('Position',[100 100 300 300],'Renderer','painters')
    imagesc(trials_tone(sortIdx,:))
    colormap gray
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    fpath = fullfile(p.out_dir,'fig1','example_cell_tone_aligned.svg');
    saveas(gca,fpath,'svg')

    figure('Position',[100 100 300 300],'Renderer','painters')
    imagesc(trials_shuttle(sortIdx,:))
    colormap gray
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    fpath = fullfile(p.out_dir,'fig1','example_cell_action_aligned.svg');
    saveas(gca,fpath,'svg')
    
    
    % calculate trial average with all trials that are long enough 
    % (shuttle start after 3s)
    fil = shuttle_times > 15;
    win = 21:40;
    t_av_tone = mean(trials_tone(fil,win));
    
    win = 61:80;
    t_av_shuttle = mean(trials_shuttle(fil,win));
    
    lims = [-.5 2];
    figure('Position',[100 100 300 300],'Renderer','painters')
    hold on
    plot(t_av_tone,'k','LineWidth',2)
    ylim(lims)
    plot([5,5],lims,'Color',[.7 .7 .7])
    set(gca,'XTick',[0 5 10 15 20]) 
    set(gca,'XTickLabel',[-1 0 1 2 3])
    xlabel('time from tone start (s)')
    ylabel('\DeltaF/F (%)')
    fpath = fullfile(p.out_dir,'fig1','example_cell_tone_aligned_average.svg');
    saveas(gca,fpath,'svg')
    
    figure('Position',[100 100 300 300],'Renderer','painters')
    hold on
    plot(t_av_shuttle,'k','LineWidth',2)
    ylim(lims)
    plot([15,15],lims,'Color',[.7 .7 .7])
    set(gca,'XTick',[0 5 10 15 20]) 
    set(gca,'XTickLabel',[-3 -2 -1 0 1])
    xlabel('time from shuttle start (s)')
    ylabel('\DeltaF/F (%)')
    fpath = fullfile(p.out_dir,'fig1','example_cell_action_aligned_average.svg');
    saveas(gca,fpath,'svg')
end