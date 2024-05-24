
%% plot raw frame and overlay
figure('Position',[200 200 300 300],'Renderer','painters')
hold on
imagesc(frame_fil)
%imagesc(frame_aligned)
colormap gray
for i=1:length(cvxHulls)
    % theres a shift when saving the image.. counteract here 
    plot(cvxHulls{i}(:,1)-2,cvxHulls{i}(:,2)-2,'Color',[0 1 0 0.5]) 
end    

set(gca,'XTick',[])
set(gca,'YTick',[])
xlim([1 size(frame_fil,2)])
ylim([1 size(frame_fil,1)-2])
set(gca, 'YDir','reverse')

if saveFigs
    fpath = fullfile(p.out_dir,'fig1','cell_map_outlines.svg');
    saveas(gca,fpath,'svg')
end

%% plot std frame and overlay
figure('Position',[200 200 300 300],'Renderer','painters')
hold on
imagesc(std_frame)
colormap gray
for i=1:length(cvxHulls)
    % theres a shift when saving the image.. counteract here 
    plot(cvxHulls{i}(:,1)-2,cvxHulls{i}(:,2)-2,'Color',[0 1 0 0.5]) 
end    

set(gca,'XTick',[])
set(gca,'YTick',[])
xlim([1 size(std_frame,2)])
ylim([1 size(std_frame,1)-2])
set(gca, 'YDir','reverse')

if saveFigs
    fpath = fullfile(p.out_dir,'figS3','cell_map_std.svg');
    saveas(gca,fpath,'svg')
end


