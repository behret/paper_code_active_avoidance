%% load centroids, tis, evs
clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs')
[cols,alpha] = chooseColors;

pad_pre = 5;
pad_post = 10;

%% get traces

for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        pos_traces{sub,ses} = [];
        pos_traces_aligned{sub,ses} = [];
        for tr = 1:length(tis{sub,ses})
            if tis{sub,ses}(3,tr) == 0
                action_start = tis{sub,ses}(1,tr) + tis{sub,ses}(12,tr);
                win = action_start-pad_pre:action_start+pad_post;
                this_trace = bvs{sub,ses}(1:2,win);
                pos_traces{sub,ses} = cat(3,pos_traces{sub,ses},this_trace);
                
                this_trace = align_trial_traces(this_trace);
                pos_traces_aligned{sub,ses} = cat(3,pos_traces_aligned{sub,ses},this_trace);
            end
        end
    end
end

%% plot all traces on top of cage image
% without alignment (no start stop markers)

% generate stitched ref frame
load(fullfile(p.data_dir ,'reference_frames.mat'))
load(fullfile(p.data_dir ,'stitching_masks_2DAA.mat'))

leftImWarped = rot90(warpIm(rot90(reference_frame2,2),bm2),2);
rightImWarped = warpIm(reference_frame1,bm1);    
ref_pic = rot90(uint8([leftImWarped rightImWarped]));
        
for sub = 6%1:p.nSubjects

    % TASK 1
    figure('Position',[100 100 500 250])
    imagesc(ref_pic')
    colormap gray
    hold on
    this_traces = cat(3,pos_traces{sub,3:4});
    for tr = 1:size(this_traces,3)
        trace = this_traces(:,:,tr);
        plot(trace(2,:),trace(1,:),'color',cols(3,:))
    end
    xlim([1 848])
    ylim([1 428])
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    xlabel('box dim. 1')
    ylabel('box dim. 2')
    
    fpath = fullfile(p.out_dir,'figS1','trace_on_ref_frame_t1');
    saveas(gca,fpath,'svg')

    
    % TASK 2
    figure('Position',[100 100 500 250])
    imagesc(ref_pic')    
    colormap gray
    hold on
    this_traces = cat(3,pos_traces{sub,5:9});
    for tr = 1:size(this_traces,3)
        trace = this_traces(:,:,tr);
        plot(trace(2,:),trace(1,:),'color',cols(4,:))
    end
    xlim([1 848])
    ylim([1 428])
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    xlabel('box dim. 1')
    ylabel('box dim. 2')

    fpath = fullfile(p.out_dir,'figS1','trace_on_ref_frame_t2');
    saveas(gca,fpath,'svg')
end



%% calculate mean of aligned traces and plot
figure('Position',[100 100 600 300])
angles_t1 = [];
angles_t2 = [];
for sub = 1:p.nSubjects
    traces_t1 = cat(3,pos_traces_aligned{sub,2:4});
    traces_t2 = cat(3,pos_traces_aligned{sub,5:9});

    mean_trace_t1 = mean(traces_t1,3);
    mean_trace_t2 = mean(traces_t2,3);

    subplot(3,4,sub)
    hold on
    plot(mean_trace_t1(2,:),mean_trace_t1(1,:),'Color',cols(3,:),'LineWidth',2)
    plot(mean_trace_t2(2,:),mean_trace_t2(1,:),'Color',cols(4,:),'LineWidth',2)

    xlim([1 848])
    ylim([1 428])
    set(gca,'XTick',[])
    set(gca,'YTick',[])  
    
end
fpath = fullfile(p.out_dir,'figS1','mean_shuttle_traces_all_subs');
saveas(gca,fpath,'svg')



%% pool trials over tasks and calculate angle between start point and crossing point
angles_t1 = {};
angles_t2 = {};
count = 0;
for sub = 1:p.nSubjects
    
    % TASK 1
    this_traces = cat(3,pos_traces_aligned{sub,2:4});
    for tr = 1:size(this_traces,3)
        trace = this_traces(:,:,tr);
        shut_idx = find(trace(2,:) > 424,1,'first');
        if isempty(shut_idx)
            [~,shut_idx] = min(424-trace(2,:));
            count = count+1
        end
        trace = trace(:,1:shut_idx);
        
        start_point = [trace(1,1) trace(2,1)];
        end_point = [trace(1,shut_idx) trace(2,shut_idx)];
        vec = end_point - start_point;
        angles_t1{sub}(tr) = atan2d(vec(1),vec(2));
    end
        
    % TASK 2
    this_traces = cat(3,pos_traces_aligned{sub,5:9});
    for tr = 1:size(this_traces,3)
        trace = this_traces(:,:,tr);
        shut_idx = find(trace(1,:) > 214,1,'first');
        if isempty(shut_idx)
            [~,shut_idx] = min(214-trace(1,:));
            count = count+1
        end
        trace = trace(:,1:shut_idx);
        
        start_point = [trace(1,1) trace(2,1)];
        end_point = [trace(1,shut_idx) trace(2,shut_idx)];
        vec = end_point - start_point;
        angles_t2{sub}(tr) = atan2d(vec(1),vec(2));
    end
end

%% boxplots for shuttle angles
figure('Position',[100 100 500 250])
plot_data = [];
groups = [];
for sub = 1:12
    plot_data = cat(2,plot_data,angles_t1{sub});
    groups = cat(2,groups,ones(1,length(angles_t1{sub}))*(sub-1)*2+1);
    plot_data = cat(2,plot_data,angles_t2{sub});
    groups = cat(2,groups,ones(1,length(angles_t2{sub}))*(sub)*2);
end

boxplot(plot_data,groups,'Symbol','k.')

h = findobj(gca,'Tag','Box');
for j=1:length(h)
    if mod(j,2) == 0
        col = cols(3,:);
    else
        col = cols(4,:);
    end
    patch(get(h(j),'XData'),get(h(j),'YData'),col,'FaceAlpha',.8);
    
end

ylim([-45 180])
set(gca,'XTick',1.5:2:23.5)
set(gca,'YTick',[-45 0 45 90 135 180])
set(gca,'XTickLabel',1:12)
xlabel('Subjects')
ylabel('Shuttle Angle (deg.)')

fpath = fullfile(p.out_dir,'figS1','mean_shuttle_angles_box_plot');
saveas(gca,fpath,'svg')
