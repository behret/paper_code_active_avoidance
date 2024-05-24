
[cols,alpha] = chooseColors;


%% plot removal from time dependent decoders

for config = 1:4
    figure('Position',[100 100 300 300])
    hold on

    % set lims and labels
    xlim([0 21])
    set(gca,'XTick',[0 5 10 15 20])
    set(gca,'XTickLabel',-3:1)
    xlabel('Time (s)')
    ylabel('Accuracy (%)')

    % indicate action start
    plot([15 15],[40 100],'k','HandleVisibility','off')

    this_cols = {};
    if any(config == [2 4]) % ITI 
        this_cmap = spring;
        this_cols{1} = 'm';
        this_cols{2} = this_cmap(30,:);
        this_cols{3} = this_cmap(40,:);
        this_cols{4} = this_cmap(50,:);
        this_cols{5} = this_cmap(64,:);
    else % A/E
        this_cmap = winter;
        this_cols{1} = 'k';
        this_cols{2} = this_cmap(1,:);
        this_cols{3} = this_cmap(25,:);
        this_cols{4} = this_cmap(45,:);
        this_cols{5} = this_cmap(60,:);
    end

    % removal_accs_time{rep,config}: dc_rep / time / iter
    for i = 1:size(removal_accs_time{1,config},3)
        dc_means = cellfun(@(x) squeeze(mean(x(:,:,i))),removal_accs_time(:,config),'UniformOutput',false);
        rep_mean = mean(cat(1,dc_means{:}));
        plot(rep_mean*100,'Color',this_cols{i},'LineWidth',2)
    end
    
    if saveFigs
        fpath = fullfile(p.out_dir,'fig3',['removal_analysis_' num2str(config) '.svg']);
        saveas(gca,fpath,'svg')
    end
end 


%% plot with CIs

time_av_win = 1:20;

this_cols{1} = 'k';
this_cols{2} = 'm';
this_cols{3} = 'k';
this_cols{4} = 'm';

for i = 1:2
    figure('Position',[100 100 300 300])
    hold on

    if i == 1
        cs = [1 2];
    else
        cs = [3 4];
    end

    cis = {};
    for config = 1:2
        this_c = cs(config);
        dc_means = cellfun(@(x) squeeze(mean(x)),removal_accs_time(:,this_c),'UniformOutput',false);
        dc_means = cat(3,dc_means{:});
        time_means = squeeze(mean(dc_means(time_av_win,:,:)));
        deltas = time_means(1,:) - time_means(1:5,:);
        deltas = -deltas'*100;
       
        sample_mean = mean(deltas);
        for t = 1:size(deltas,2)
            acc_sorted = sort(deltas(:,t));
            if size(acc_sorted,1) ~= 80
                disp('Number of reps needs to be 80 for CIs')
            end
            ci_high(t) = acc_sorted(78);
            ci_low(t) = acc_sorted(3);           
        end
        plot(sample_mean,'Color',this_cols{this_c},'LineWidth',2)
        x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
        ci_data = [ci_low, fliplr(ci_high)];
        fill(x_data, ci_data , 1,....
                'facecolor',this_cols{this_c}, ...
                'edgecolor','none', ...
                'facealpha', alpha,...
                'HandleVisibility','off');
        
        cis{config} = [ci_low ; ci_high];
    end
    set(gca,'XTick',1:5)
    set(gca,'XTickLabel',0:4)
    xlabel('# Dim. Removed')
    ylabel('\Delta Mean Acc. (%)')
    if i == 1
        x_val_sig = -9;
        lims = [-10 1];
    else
        x_val_sig = -18;
        lims = [-20 2];
    end
    xlim([.5 5])
    ylim(lims)
    
    % plot chosen
    plot([3 3],lims,'--','Color',[.7 .7 .7],'LineWidth',2)

    
    % plot significance
    for t = 1:length(cis{1})
        % check if upper or lower val of setting 1 is within the bounds
        % of setting 2
        lower_in = cis{1}(1,t) > cis{2}(1,t)  && cis{1}(1,t) < cis{2}(2,t);
        upper_in = cis{1}(2,t) > cis{2}(1,t)  && cis{1}(2,t) < cis{2}(2,t);
        sig(t) = ~(lower_in || upper_in);
        
        if sig(t) & t > 1
            plot([t-.5 t+.5],[x_val_sig x_val_sig],'k','LineWidth',3)
        end
    end

    if saveFigs
        fpath = fullfile(p.out_dir,'fig3',['removal_analysis_summary_' num2str(i) '.svg']);
        saveas(gca,fpath,'svg')
    end
end

