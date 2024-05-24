%%

[cols,alpha] = chooseColors;

this_cols{1} = 'k';
this_cols{2} = cols(2,:);
this_cols{3} = [.7 .7 .7];

%% plot accs over time for using all 5 dimensions

figure('Position',[100 100 300 300])
hold on

for config = 1:3
    dc_means = cellfun(@(x) squeeze(mean(x,1))',td_accs,'UniformOutput',false);
    rep_mean = mean(cat(2,dc_means{:,config,6}),2);
    plot(rep_mean*100,'LineWidth',2,'Color',this_cols{config})
end

plot([15 15],[50 100],'Color',[.7 .7 .7])

% set lims and labels
xlim([0 21])
set(gca,'XTick',[0 5 10 15 20])
set(gca,'XTickLabel',-3:1)
xlabel('Time (s)')
ylabel('Task-decoding Acc. (%)')
if saveFigs
    fpath = fullfile(p.out_dir,'fig6','task_decoding_per_timestep.svg');
    saveas(gca,fpath,'svg')
end


%% plot mean acc over time for using all 5 dims
% custom plot of CIs. color CIs and make violin gray
temp_mean = [];
for config = 1:3
    dc_means = cellfun(@(x) squeeze(mean(x,1))',td_accs,'UniformOutput',false);
    temp_mean(config,:) = mean(cat(2,dc_means{:,config,6}),1)*100;
end

figure('Position',[100 100 300 300])
hold on

for i = 1:3
    % plot distribution
    this_accs = temp_mean(i,:)';
    distributionPlot(this_accs,'color',[.9 .9 .9],'histOpt',1,'xValues',i,'showMM',0)

    % plot mean and CI
    sorted = sort(this_accs);
    if size(this_accs,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high = sorted(78);
    ci_low = sorted(3);    
    this_mean = mean(this_accs);
    plot(i,this_mean,'o','color',this_cols{i},'MarkerFaceColor',this_cols{i})
    errorbar(i,this_mean,this_mean-ci_low,this_mean-ci_high,'color',this_cols{i})
end
ylim([50 85])
ylabel('Mean Accuracy (%)')
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'Avoid','Error','ITI'})


if saveFigs
    fpath = fullfile(p.out_dir,'fig6','task_decoding_mean_accs.svg');
    saveas(gca,fpath,'svg')
end


%% plot accuracy for the individual dimensions for all 3 configs
figure('Position',[100 100 900 300])
hold on
count = 0;
for config = 1:3
    for d = 1:5
        count = count+1;
        % plot distribution
        dc_means = cellfun(@(x) mean(x(:)),td_accs);
        this_accs = squeeze(dc_means(:,config,:));
        this_accs = this_accs(:,d)*100;
        distributionPlot(this_accs,'color',[.9 .9 .9],'histOpt',1,'xValues',count,'showMM',0)

        % plot mean and CI
        sorted = sort(this_accs);
        if size(this_accs,1) ~= 80
            disp('Number of reps needs to be 80 for CIs')
        end
        ci_high = sorted(78);
        ci_low = sorted(3);    
        this_mean = mean(this_accs);
        plot(count,this_mean,'o','color',this_cols{config},'MarkerFaceColor',this_cols{config})
        errorbar(count,this_mean,this_mean-ci_low,this_mean-ci_high,'color',this_cols{config})
    end
    count = count+2;
end
ylim([45 75])
ylabel('Acc. (%)')
xlabel('Dim.')
set(gca,'XTick',[1:5 8:12 15:19])
set(gca,'XTickLabel',{'M1','M2','A1','A2','T'})

if saveFigs
    fpath = fullfile(p.out_dir,'fig6','task_decoding_per_dim.svg');
    saveas(gca,fpath,'svg')
end
