[cols,alpha] = chooseColors;

%% plot with CI
    
    for k = 1:2
        figure('Position',[100 100 300 300])
        hold on
        lims = [40 100];

        this_cols = {'k','m','k','m',[.7 .7 .7],[.7 .7 .7],[.7 .7 .7],[.7 .7 .7]};

        if k == 1 
            is = 1:2;
        elseif k == 2
            is = 3:4;
        elseif k == 3
            is = [1 5];
        elseif k == 4
            is = [3 7];
        end
            
        count = 1;
        cis = {};
        for i = is
            dc_rep_mean = squeeze(mean(all_acc(:,i,:,:),3))*100;
            sample_mean = mean(dc_rep_mean);
            for t = 1:size(dc_rep_mean,2)
                acc_sorted = sort(dc_rep_mean(:,t));
                if size(acc_sorted,1) ~= 80
                    disp('Number of reps needs to be 80 for CIs')
                end
                ci_high(t) = acc_sorted(78);
                ci_low(t) = acc_sorted(3);           
            end
            plot(sample_mean,'Color',this_cols{i},'LineWidth',2)
            x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
            ci_data = [ci_low, fliplr(ci_high)];
            fill(x_data, ci_data , 1,....
                    'facecolor',this_cols{i}, ...
                    'edgecolor','none', ...
                    'facealpha', alpha,...
                    'HandleVisibility','off');
            cis{count} = [ci_low ; ci_high];
            count = count+1;
        end

        set(gca,'XTick',[0 5 10 15 20]) 
        set(gca,'XTickLabel',-3:1)
        plot([15 15],lims,'Color',[.7 .7 .7],'HandleVisibility','off')

        ylabel('Accuracy (%)')
        xlabel('Time (s)')
        ylim(lims)
        xlim([0 20])
        
        plot([0 20],[50 50],'--','Color',[.7 .7 .7])
        
     
        for t = 1:length(cis{1})
            % check if upper or lower val of setting 1 is within the bounds
            % of setting 2
            lower_in = cis{1}(1,t) > cis{2}(1,t)  && cis{1}(1,t) < cis{2}(2,t);
            upper_in = cis{1}(2,t) > cis{2}(1,t)  && cis{1}(2,t) < cis{2}(2,t);
            sig(t) = ~(lower_in || upper_in);
            
            if sig(t) 
                plot([t-.5 t+.5],[45 45],'k','LineWidth',3)
            end
        end

        if saveFigs
            if k == 1
                fpath = fullfile(p.out_dir,'fig2','basic_decoding_ae.svg');
            else
                fpath = fullfile(p.out_dir,'fig2','basic_decoding_iti.svg');
            end
            saveas(gca,fpath,'svg')
        end
    end
