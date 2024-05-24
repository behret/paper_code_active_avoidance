%%
% AV/ERR/ITI/Rand
[cols,alpha] = chooseColors;
this_cols = {'k',cols(2,:),'m',[.7 .7 .7]};

%% plot mean speeds for AV/ERR and ITI/Rand
lims = [0 30];
figure('Position',[100 100 300 300])
hold on

% AV/ERR
plot(squeeze(mean(mean(av_trials,1),3))*0.06,'Color',this_cols{1},'LineWidth',2)
plot(squeeze(mean(mean(err_trials,1),3)*0.06),'Color',this_cols{2},'LineWidth',2)
set(gca,'XTick',[0 5 10 15 20]) 
set(gca,'XTickLabel',-3:1)
plot([15 15],lims,'Color',[.7 .7 .7],'HandleVisibility','off')
ylabel('Speed (cm/s)')
xlabel('Time (s)')
ylim(lims)
xlim([0 20])

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','av_err_spd.svg');
    saveas(gca,fpath,'svg')
end

% ITI/rand
figure('Position',[100 100 300 300])
hold on
plot(squeeze(mean(mean(av_trials_iti,1),3))*0.06,'Color',this_cols{3},'LineWidth',2)
plot(squeeze(mean(mean(err_trials_iti,1),3))*0.06,'Color',this_cols{4},'LineWidth',2)
set(gca,'XTick',[0 5 10 15 20]) 
set(gca,'XTickLabel',-3:1)
plot([15 15],lims,'Color',[.7 .7 .7],'HandleVisibility','off')
ylabel('Speed (cm/s)')
xlabel('Time (s)')
ylim(lims)
xlim([0 20])

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','iti_rand_spd.svg');
    saveas(gca,fpath,'svg')
end


%%
mean_spds = [];
mean_spds{1} = squeeze(mean(mean(av_trials(:,11:20,:),2)))*0.06;
mean_spds{2} = squeeze(mean(mean(err_trials(:,11:20,:),2)))*0.06;  
mean_spds{3} = squeeze(mean(mean(av_trials_iti(:,11:20,:),2)))*0.06;
mean_spds{4} = squeeze(mean(mean(err_trials_iti(:,11:20,:),2)))*0.06;
bin_edges = 0:30;

% AV/ITI
figure('Position',[100 100 300 300])
hold on
histogram(mean_spds{1},bin_edges,'Normalization','probability','FaceColor',this_cols{1})
histogram(mean_spds{3},bin_edges,'Normalization','probability','FaceColor',this_cols{3})
xlabel('Mean speed (cm/s)')
ylabel('Probability')

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','spd_hist_av_iti.svg');
    saveas(gca,fpath,'svg')
end



% ERR/Rand
figure('Position',[100 100 300 300])
hold on
histogram(mean_spds{2},bin_edges,'Normalization','probability','FaceColor',this_cols{2})
histogram(mean_spds{4},bin_edges,'Normalization','probability','FaceColor',this_cols{4})
xlabel('Mean speed (cm/s)')
ylabel('Probability')

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','spd_hist_err_rand.svg');
    saveas(gca,fpath,'svg')
end


%% calculate d-prime and correlate UMAP D1 and speed

for rep = 1:length(reduction)
    for i = 1:2
        for j = 1:4
            mns(rep,i,j) = mean(reduction{rep}(labs == j,i));
            sds(rep,i,j) = std(reduction{rep}(labs == j,i));
        end
    end
end

ccs = [];
for rep = 1:length(reduction)
    dps(rep,1) = (mns(rep,1,1) - mns(rep,1,2))/mean([sds(rep,1,1) sds(rep,1,2)]);
    dps(rep,2) = (mns(rep,1,3) - mns(rep,1,4))/mean([sds(rep,1,3) sds(rep,1,4)]);
    dps(rep,3) = (mns(rep,2,1) - mns(rep,2,2))/mean([sds(rep,2,1) sds(rep,2,2)]);
    dps(rep,4) = (mns(rep,2,3) - mns(rep,2,4))/mean([sds(rep,2,3) sds(rep,2,4)]);


    cc = corrcoef(cat(1,mean_spds{:}),reduction{rep}(:,1));
    ccs(rep,1) = cc(1,2);
    cc = corrcoef(cat(1,mean_spds{:}),reduction{rep}(:,2));
    ccs(rep,2) = cc(1,2);
end
    

figure('Position',[100 100 200 300])
hold on
boxplot(-dps,'Color','k')
ylim([-1 4])
ylabel('D-prime')
set(gca,'XTick',[1 2 3 4])
set(gca,'XTickLabel',{'Av/Err','ITI'})
xtickangle(45)
area([0 2.5],[4 4],'FaceColor',[.7 .7 .7],'FaceAlpha',alpha,'LineStyle','none','BaseValue',-3)

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','d_primes.svg');
    saveas(gca,fpath,'svg')
end

figure('Position',[100 100 150 300])
boxplot(-ccs,'Color','k')
ylim([-.5 1])
ylabel('Corr. to mean speed')
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'UMAP D1','UMAP D2'})
xtickangle(45)

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','corr_umap_spd.svg');
    saveas(gca,fpath,'svg')
end

%% plot UMAP projection for every data point (choose rep with high d-prime)

rep = 4;

figure('Position',[100 100 300 300])
hold on
for i = 1:size(labs,2)
    plot(reduction{rep}(i,1),reduction{rep}(i,2),'.','Color',this_cols{labs(i)})
end
xlabel('UMAP Dim. 1')
ylabel('UMAP Dim. 2')

if saveFigs
    fpath = fullfile(p.out_dir,'figS7','umap.svg');
    saveas(gca,fpath,'svg')
end

%% plot histogram for the 4 trial types for both UMAP dims

for i = 1:2
    figure('Position',[100 100 300 300])
    hold on
    bins = floor(min(reduction{rep}(:,i))):0.5:ceil(max(reduction{rep}(:,i)));
    for j = 1:4
        histogram(reduction{rep}(labs == j,i),bins,'Normalization','probability','FaceColor',this_cols{j})
    end
        
    xlabel(['UMAP Dim. ' num2str(i)])
    ylabel('Probability')

    if saveFigs
        fpath = fullfile(p.out_dir,'figS7',['umap_hist_dim' num2str(i) '.svg']);
        saveas(gca,fpath,'svg')
    end
end

