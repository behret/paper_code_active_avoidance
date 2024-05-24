    %% make individual plots for fig for chosen cells
    for j = 1:2
        if j == 1
            fpath = [p.data_dir '\annotation_examples_good'];
        else
            fpath = [p.data_dir '\annotation_examples_bad'];
        end
        load(fpath,'this_traces','this_filters','this_events','this_snapshotCollections')
        i = 1;

        % plot filter
        figure('Position',[100 100 300 300])
        imagesc(this_filters(:,:,i));
        xlim([1,size(this_filters,2)])
        ylim([1,size(this_filters,1)])
        axis off
        title('Spatial Filter')

        fpath = fullfile(p.out_dir,'figS4',['filter' num2str(j)]);
        saveas(gca,fpath,'svg')
        
        % plot average transient
        figure('Position',[100 100 300 300])
        hold on
        % get cutouts around events
        transMat = [];
        for e = 1:length(this_events{i})
            if this_events{i}(e)>20 && this_events{i}(e) < size(this_traces,2)-30
                thisTrans = this_traces(i,this_events{i}(e)-20:this_events{i}(e)+30);
                transMat = cat(1,transMat,thisTrans);
            end
        end
        if ~isempty(transMat)
            plot(-20:1:30,transMat','k')
            plot(-20:1:30,nanmean(transMat,1),'r','LineWidth',2)
            set(gca,'xlim',[-20 30],'ylim',[min(transMat(:)) max(transMat(:))],'ytick',[])
            set(gca,'XTick',[-20,0,30])
            set(gca,'XTickLabel',[-4 0 6])
            xlabel('Time (s)')
        end
        clear e transMat
        title('Mean Transient')

        fpath = fullfile(p.out_dir,'figS4',['average_transient' num2str(j)]);
        saveas(gca,fpath,'svg')

        % Plot whole trace
        figure('Position',[100 100 1400 300])
        hold on
        for d = 1:11
            if mod(d,2) == 1
                this_col = [.4 .4 .4];
            else
                this_col = [.7 .7 .7];
            end
            t_start = (d-1)*12000+1;
            t_end = d*12000;
            area([t_start t_end],[max(this_traces(i,:))*1.2 max(this_traces(i,:))*1.2],...
                'FaceColor',this_col,'FaceAlpha',.3,'BaseValue',min(this_traces(i,:))*1.2,...
                'LineStyle','none')
        end
        plot(this_traces(i,:),'k')
        if ~isempty(this_events{i})
            plot(this_events{i},this_traces(i,this_events{i}),'ro','MarkerSize',3,'MarkerFaceColor','r');
        end
        set(gca,'ylim',[min(this_traces(i,:))*1.2 max(this_traces(i,:))*1.2])
        set(gca,'YTick',[])
        title('Full Activity Trace')
        set(gca,'XTick',[0,size(this_traces,2)])
        display_len = round(size(this_traces,2)/(p.frameRate*60));
        frame_lim = display_len * (p.frameRate*60);
        set(gca,'XTickLabel',[0 display_len])
        xlim([0 frame_lim])
        xlabel('Time (min)')

        fpath = fullfile(p.out_dir,'figS4',['full_trace' num2str(j)]);
        saveas(gca,fpath,'svg')
        
        % plot trace zoom in 
        figure('Position',[100 100 700 300])
        hold on
        plot(this_traces(i,:),'k')
        if ~isempty(this_events{i})
            plot(this_events{i},this_traces(i,this_events{i}),'ro','MarkerSize',3,'MarkerFaceColor','r');
        end
        set(gca,'ylim',[min(this_traces(i,:))*1.2 max(this_traces(i,:))*1.2])
        set(gca,'YTick',[])
        display_len = round(size(this_traces,2)/(p.frameRate*60));
        frame_lim = display_len * (p.frameRate*60);
        if j == 1
            win = [25600 26800];
        elseif j == 2
            win = [72800 74000];
        end
        xlim(win)
        set(gca,'XTick',[win(1) win(1)+300 win(1)+600 win(1)+900 win(1)+1200])
        set(gca,'XTickLabel',0:4)
        xlabel('Time (min)')
        fpath = fullfile(p.out_dir,'figS4',['trace_zoom_in' num2str(j)]);
        saveas(gca,fpath,'svg')
        
        
        % plot event montage
        figure('Position',[100 100 1400 300])
        imagesc(this_snapshotCollections{i})
        title(['Snapshots of ' num2str(length(this_events{i})) ' events'])
        axis off
        fpath = fullfile(p.out_dir,'figS4',['event_snapshots' num2str(j)]);
        saveas(gca,fpath,'svg')
    end
    