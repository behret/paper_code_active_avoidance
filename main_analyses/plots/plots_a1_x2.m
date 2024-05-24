%% plot av/err vs iti/rand for different number of iti transitions
[cols,alpha] = chooseColors;

figure
for g = 1:length(gaging_var)
    subplot(2,3,g)
    hold on
    % plot av/err
    dc_rep_mean = squeeze(mean(all_acc(:,g,1,:,:),4))*100;
    sample_mean = mean(dc_rep_mean);
    plot(sample_mean,'Color','k','LineWidth',2)
    
    % plot av/err
    dc_rep_mean = squeeze(mean(all_acc(:,g,2,:,:),4))*100;
    sample_mean = mean(dc_rep_mean);
    plot(sample_mean,'Color','g','LineWidth',2)
    
    title(gaging_var(g))
end

%% choose some g's to display in one plot for Fig.
lims = [40 100];
figure('Position',[100 100 300 300])
hold on
% plot av/err
dc_rep_mean = squeeze(mean(all_acc(:,1,1,:,:),4))*100;
sample_mean = mean(dc_rep_mean);
plot(sample_mean,'Color','k','LineWidth',2)

cmap = winter;
this_cols{1} = cmap(1,:);
this_cols{2} = cmap(30,:); 
this_cols{3} = cmap(64,:);

gs = [1 3 5];

for g = 1:3
    % plot av/err
    dc_rep_mean = squeeze(mean(all_acc(:,gs(g),2,:,:),4))*100;
    sample_mean = mean(dc_rep_mean);
    plot(sample_mean,'Color',this_cols{g},'LineWidth',2)
end

set(gca,'XTick',[0 5 10 15 20]) 
set(gca,'XTickLabel',-3:1)
plot([15 15],lims,'Color',[.7 .7 .7],'HandleVisibility','off')
ylabel('Accuracy (%)')
xlabel('Time (s)')
ylim(lims)
xlim([0 20])

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','iti_gaging_decoding_acc.svg');
    saveas(gca,fpath,'svg')
end
%% plot summary measure:
% - difference in predicitve accuracy (2s before action start) between av/err and iti/rand
% - mean accuracy of av/iti

time_win = 6:15;
deltas = [];
mean_diff = [];
mean_av_iti = [];
for g = 1:length(gaging_var)
    
    % for deltas first calc 
    dc_rep_mean_av = squeeze(mean(all_acc(:,g,1,:,:),4))*100;
    dc_rep_mean_iti = squeeze(mean(all_acc(:,g,2,:,:),4))*100;

    % do temporal averaging
    pred_acc_av = mean(dc_rep_mean_av(:,time_win),2);
    pred_acc_iti = mean(dc_rep_mean_iti(:,time_win),2);
    deltas(:,g) = pred_acc_av-pred_acc_iti;
end

figure('Position',[100 100 300 300])
hold on
sample_mean = mean(deltas);
for t = 1:size(deltas,2)
    acc_sorted = sort(deltas(:,t));
    if size(acc_sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = acc_sorted(78);
    ci_low(t) = acc_sorted(3);           
end
plot(sample_mean,'Color','k','LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
ci_data = [ci_low, fliplr(ci_high)];
fill(x_data, ci_data , 1,....
        'facecolor','k', ...
        'edgecolor','none', ...
        'facealpha', alpha,...
        'HandleVisibility','off');
    plot([5 5],[-2 4],'Color',[.7 .7 .7])

plot([0 7],[0 0],'--','Color',[.7 .7 .7])
    
xlabel('n')
set(gca,'XTick',1:length(gaging_var))
set(gca,'XTickLabel',gaging_var)
ylabel('\Delta Pred. Accuracy (%)')
xlim([0 length(gaging_var)+1])

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','iti_gaging_acc_delta.svg');
    saveas(gca,fpath,'svg')
end

%% plot mean speed (trial-mean) for different g's

figure('Position',[100 100 300 300])
hold on
% plot AV
rep_mean = mn_spd_trials{1,1};
plot(rep_mean,'Color','k','LineWidth',2)

% plot ITI for 3 g's 
for g = 1:3
    rep_mean = mn_spd_trials{gs(g),2};
    plot(rep_mean,'Color',this_cols{g},'LineWidth',2)
end

set(gca,'XTick',[0 5 10 15 20]) 
set(gca,'XTickLabel',-3:1)
plot([15 15],[0 30],'Color',[.7 .7 .7],'HandleVisibility','off')
ylabel('Speed (cm/s)')
xlabel('Time (s)')
xlim([0 20])

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','iti_gaging_mean_speed.svg');
    saveas(gca,fpath,'svg')
end

%% plot mean speed (time-mean) for different g's

figure('Position',[100 100 300 300])
hold on

% plot AV
mn_spd_dist = cat(2,mn_spd_time{1,1}); % just take one rep here
av_mn = mean(mn_spd_dist);
bins = 0:30;
% plot ITI for 3 g's 
for g = 1:3
    mn_spd_dist = cat(2,mn_spd_time{gs(g),2}); % just take one rep here
    histogram(mn_spd_dist,bins,'FaceColor',this_cols{g},'FaceAlpha',.5)
    dist_mn = mean(mn_spd_dist);
    plot([dist_mn],[400],'Color',this_cols{g},'Marker','o','MarkerFaceColor',this_cols{g})
end

xlim([0 30])
ylim([0 450])
xlabel('Mean Speed (cm/s)')
ylabel('Num. ITI Shuttles')
plot([av_mn],[400],'Color','k','Marker','o','MarkerFaceColor','k')

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','iti_gaging_speed_dist.svg');
    saveas(gca,fpath,'svg')
end