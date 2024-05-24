[cols,alpha] = chooseColors;


%% plot av1/2 over sessions

time_win = 6:15;

this_cols = {};% need to reverse order for some reason..
this_cols{1} = [208 28 139]/255;
this_cols{2} = [241 182 218]/255;
this_cols{3} = [77 172 38]/255;
this_cols{4} = [184 255 134]/255;
this_cols{5} = [67 162 202]/255;
this_cols{6} = [.7 .7 .7];

this_cols = {};
this_cols{1} = [77 172 38]/255;
this_cols{2} = [184 255 134]/255;
this_cols{3} = [.7 .7 .7];


for i = 1:2
    if i == 1
        this_av = eval_accs_1;
    else
        this_av = eval_accs_2;
    end
    
    figure('Position',[100 100 300 300])
    hold on
    % av1
    dc_means = squeeze(mean(this_av,1))*100;
    time_means = squeeze(mean(dc_means(:,time_win,:),2))';
    sample_mean = mean(time_means);
    for t = 1:size(time_means,2)
        acc_sorted = sort(time_means(:,t));
        if size(acc_sorted,1) ~= 80
            disp('Number of reps needs to be 80 for CIs')
        end
        ci_high(t) = acc_sorted(78);
        ci_low(t) = acc_sorted(3);        
    end
    plot(sample_mean,'Color',this_cols{i},'LineWidth',2)
    x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
    ci_data = [ci_low, fliplr(ci_high)];
    fill(x_data, ci_data , 1,...
            'facecolor',this_cols{i}, ...
            'edgecolor','none', ...
            'facealpha', 0.3);

    lims = [45 70];
    ylim(lims)
    xlim([0 12])
    set(gca,'XTick',[1 11])
    xlabel('Day')
    ylabel('Pred. Acc. (%)')

    plot([1.5,1.5],lims,'Color',[.7 .7 .7])
    plot([4.5,4.5],lims,'Color',[.7 .7 .7])
    plot([9.5,9.5],lims,'Color',[.7 .7 .7])

    plot([0 12],[50 50],'--','Color',[.7 .7 .7])

    cis = [ci_low;ci_high];
    % plot significance
    for t = 1:length(cis)
        % check if CI includes 50
        sig(t) = ~(cis(1,t) < 50  && cis(2,t) > 50);

        if sig(t)
            plot([t-.5 t+.5],[47 47],'k','LineWidth',3)
        end
    end
    
    if saveFigs
        fpath = fullfile(p.out_dir,'fig5',['ae_decoding_per_ses_av' num2str(i) '.svg']);
        saveas(gca,fpath,'svg')
    end
end

