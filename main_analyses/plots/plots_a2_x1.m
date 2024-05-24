%% plot projections of DR data trial average (not per task) onto spd_dims
[cols,alpha] = chooseColors;

this_cols = {};
this_cmap = spring;
this_cols{1} = this_cmap(30,:);
this_cols{2} = this_cmap(50,:);
this_cmap = winter;
this_cols{3} = this_cmap(1,:);
this_cols{4} = this_cmap(35,:);
this_cols{5} = this_cmap(64,:);

t_av = nanmean(trans_data_dr,3);
t_av = t_av-mean(t_av,2);
proj = (t_av' * spd_dims)';

lims = [-3 5];
figure('Position',[100 100 300 300])
hold on

for i = 1:5
    plot(proj(i,:),'Color',this_cols{i},'LineWidth',2)
end
plot([20 20],lims,'Color',[.7 .7 .7])
xlim([1 40])
ylim(lims)
set(gca,'XTick',[1 20 40])
set(gca,'XTickLabel',[-4 0 4])
xlabel('Time (s)')
ylabel('Projection (a.u.)')

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','motion_PCs.svg');
    saveas(gca,fpath,'svg')
end

%% plot VE
this_cols = {'k',[255,127,0]/255};

figure('Position',[100 100 300 300])
hold on
for i = 1:2
    sample_mean = squeeze(mean(explained(:,i,:)))';        
    for t = 1:size(explained,3)
        sorted = sort(explained(:,i,t));
        if size(explained,1) ~= 80
            disp('Number of reps needs to be 80 for CIs')
        end
        ci_high(t) = sorted(78);
        ci_low(t) = sorted(3);           
    end
    plot(sample_mean,'Color',this_cols{i},'LineWidth',2)
    x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
    ci_data = [ci_low, fliplr(ci_high)];
    fill(x_data, ci_data , 1,....
            'facecolor',this_cols{i}, ...
            'edgecolor','none', ...
            'facealpha', 0.3,'HandleVisibility','off');
end

xlabel('PC')
ylabel('Var. Expl. (%)')
xlim([0 6])
ylim([-10 80])
legend({'DR Data','Val. Data'})
set(gca,'XTick',1:5)

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','motion_dim_VEs.svg');
    saveas(gca,fpath,'svg')
end

%% plot actual motion

lims = [0 20];
figure('Position',[100 100 300 300])
hold on
plot(mn_iti_spd*0.06,'k','LineWidth',2)
plot([20 20],lims,'Color',[.7 .7 .7])
xlim([1 40])
ylim(lims)
set(gca,'XTick',[1 20 40])
set(gca,'XTickLabel',[-4 0 4])
xlabel('Time (s)')
ylabel('Mean Speed (cm/s)')

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','iti_speed.svg');
    saveas(gca,fpath,'svg')
end



%% plot pc1 proj per subject

lims = [-4 6];
figure('Position',[100 100 300 300])
hold on
sub_means = squeeze(mean(pc1_proj))';
plot(sub_means)
plot([20 20],lims,'Color',[.7 .7 .7])
xlim([1 40])
ylim(lims)
set(gca,'XTick',[1 20 40])
set(gca,'XTickLabel',[-4 0 4])
xlabel('Time (s)')
ylabel('PC1 Proj. (a.u.)')

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','motion_pc1_per_sub.svg');
    saveas(gca,fpath,'svg')
end

%% calc ccs and print

ccs = [];
for sub = 1:p.nSubjects
    cc = corrcoef(proj(1,:),sub_means(:,sub)');
    ccs(sub) = cc(1,2);
end

disp(['Pearson correlation coefficient: ' num2str(round(mean(ccs),3)) ' +- ' num2str(round(std(ccs),3))])


%% fig for legend
figure('Position',[100 100 400 400])
hold on
for i = 1:12
    plot([1 1],[2 2])
end
legend({'1','2','3','4','5','6','7','8','9','10','11','12'})
if saveFigs
    fpath = fullfile(p.out_dir,'figS8','legend_for_subjects.svg');
    saveas(gca,fpath,'svg')
end
