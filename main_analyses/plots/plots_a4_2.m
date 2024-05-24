[cols,alpha] = chooseColors;

this_cols{1} = cols(3,:); % t2xy vs. t2y
this_cols{2} = cols(4,:); % t2xy vs. t1x

td_accs = td_accs(:,[2 1],:);

%% plot mean acc over time for using all 5 dims
% custom plot of CIs. color CIs and make violin gray
temp_mean = [];
for config = 1:2
    dc_means = cellfun(@(x) squeeze(mean(x,1))',td_accs,'UniformOutput',false);
    temp_mean(config,:) = mean(cat(2,dc_means{:,config,6}),1)*100;
end

figure('Position',[100 100 300 300])
hold on

for i = 1:2
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
set(gca,'XTick',1:2)
set(gca,'XTickLabel',{'',''})


if saveFigs
    fpath = fullfile(p.out_dir,'fig6','trial_group_decoding_all_dims.svg');
    saveas(gca,fpath,'svg')
end




%%
% T2xy vs T1x: concept is different, motion is different
% T2xy vs T2y: concept is the same, motion is different

figure('Position',[100 100 600 300])
hold on
count = 0;
for config = 1:2
    for d = 1:5
        count = count+1;
        % plot distribution
        dc_means = cellfun(@(x) mean(x(:)),td_accs);
        this_accs = squeeze(dc_means(:,config,:));
        this_accs = this_accs(:,d)*100;
        distributionPlot(this_accs,'color',[.9 .9 .9],'histOpt',1,'xValues',count,'showMM',0)
        % plot mean and CI
        this_mean = mean(this_accs);
        sorted = sort(this_accs);
        if size(this_accs,1) ~= 80
            disp('Number of reps needs to be 80 for CIs')
            ci_high = this_mean;
            ci_low = this_mean;  
        else
            ci_high = sorted(78);
            ci_low = sorted(3);    
        end
        plot(count,this_mean,'o','color',this_cols{config},'MarkerFaceColor',this_cols{config})
        errorbar(count,this_mean,this_mean-ci_low,this_mean-ci_high,'color',this_cols{config})
    end
    count = count+2;
end
ylim([45 75])
ylabel('Acc. (%)')
xlabel('Dim.')
set(gca,'XTick',[1:5 8:12])
set(gca,'XTickLabel',{'M1','M2','A1','A2','T'})

if saveFigs
    fpath = fullfile(p.out_dir,'fig6','trial_group_decoding_per_dim.svg');
    saveas(gca,fpath,'svg')
end
