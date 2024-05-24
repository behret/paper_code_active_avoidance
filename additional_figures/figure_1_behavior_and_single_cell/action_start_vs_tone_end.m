% analyze action initiation:
% there is a delay between action start and tone end
% what is the distribution of this delay over trials / tasks

% - figure out action start using diff(spd)
% - align to action start vs align to tone end


%% load data

clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'tis','bvs','evs')
[cols,alpha] = chooseColors;
saveFigs = 0;

%% plot example trial: action start vs tone end
ses = 4;

for sub=5%1:p.nSubjects
    av_trials = find(tis{sub,ses}(3,:) == 0);
    pad = 10;

    figure('Position',[100 100 300 300],'Renderer','painters')
    trs = [1 2 3 4 9];
    
    for i = 1:5
        hold on
        tr = av_trials(trs(i));

        tr_start = tis{sub,ses}(1,tr);
        win = tr_start-pad:tr_start+50+pad-1;
        spd_trace = bvs{sub,ses}(3,win) * 0.06 * 0.01; % normalize    % scale bar: 0.5 = 50 cm/5
        spd_trace = spd_trace + (i-1); % shift

        plot(spd_trace,'k','LineWidth',2)

        % plot action start and tone end
        action_start = tis{sub,ses}(12,tr) + pad;
        tone_end = tis{sub,ses}(6,tr) + pad;
        plot(action_start,spd_trace(action_start),'o','MarkerFaceColor','r','MarkerEdgeColor','r')
        plot(tone_end,spd_trace(tone_end),'o','MarkerFaceColor','b','MarkerEdgeColor','b')
        plot(pad,spd_trace(pad),'o','MarkerFaceColor',[240 200 20]/255,'MarkerEdgeColor',[240 200 20]/255)
    end
    ylim([-0.5 5])
    xlim([0 71])
    set(gca,'YTick',0:4)
    set(gca,'YTickLabel',[5 4 3 2 1])
    set(gca,'XTick',[10 35 60])
    set(gca,'XTickLabel',[0 5 10])
    xlabel('time from tone start (s)')
    ylabel({'speed in', 'example trials (a.u.)'})
end
fpath = fullfile(p.out_dir,'fig1','action_start_vs_tone_end.svg');
if saveFigs
    saveas(gca,fpath,'svg')
end

%% plot distribution of shuttle start (latency)

lats = {};
dts = {};
for sub = 1:p.nSubjects
    for ses = 2:9
        av_trials = tis{sub,ses}(3,:) == 0;
        lats{sub,ses} = tis{sub,ses}(12,av_trials);
        dts{sub,ses} = tis{sub,ses}(6,av_trials) - tis{sub,ses}(12,av_trials);
    end
end

figure('Position',[100 100 300 300],'Renderer','painters')
all_lats = cat(2,lats{:});
all_dts = cat(2,dts{:});
all_lats(all_lats>50) = 50;
boxplot([all_dts ; all_lats]','Color','k','Orientation','horizontal')
set(gca,'YTick',[])
set(gca,'XTick',[0 25 50])
set(gca,'XTickLabel',[0 5 10])
xlabel('time (s)')

fpath = fullfile(p.out_dir,'fig1','shuttle_latency_and_duration.svg');
if saveFigs
    saveas(gca,fpath,'svg')
end
%%

figure('Position',[100 100 300 300],'Renderer','painters')
all_lats = cat(2,lats{:});
all_dts = cat(2,dts{:});
all_lats(all_lats>50) = 50;

hold on 
histogram(all_dts,0:2:50,'FaceColor',[.4 .4 .4])
histogram(all_lats,0:2:50,'FaceColor',[.8 .8 .8])

set(gca,'XTick',[0 25 50])
set(gca,'XTickLabel',[0 5 10])
xlabel('time (s)')
ylabel('trials')
xlim([0 50])

fpath = fullfile(p.out_dir,'fig1','shuttle_latency_and_duration_histograms.svg');
if saveFigs
    saveas(gca,fpath,'svg')
end

