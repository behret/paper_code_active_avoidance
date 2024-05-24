function playMovieCutout(movieCutout, traceCutout, cellOutline, neighborOutlines )
    
    % resize movie cutout (was compressed to save memory)
    movieCutout = imresize(movieCutout,2);

    % set display params
    windowSpace = 20;
    windowTime = 20;
    waitTime = 1/(windowTime);
    
    % set color values
    minVals=min(movieCutout,[],3);
    maxVals=max(movieCutout,[],3);
    clims = [prctile(minVals(:),50) prctile(maxVals(:),99)];

    f = figure('WindowStyle','normal','Position',[100,200,500,400]);
    for i = 1:size(movieCutout,3)
        % plot movie
        % had to flip first dim of movie
        ax = subplot(3,2,[1:4]);
        hold on
        imagesc(flipud(movieCutout(:,:,i)));
        colormap(ax,gray)
        set(gca,'CLim',clims)
        set(gca, 'XTick', [], 'YTick', [])

        % plot cvxHulls
        % had to flip values for y part
        plot(cellOutline(:,1),abs(cellOutline(:,2)-40),'m')
        for j=1:length(neighborOutlines)
            plot(neighborOutlines{j}(:,1),abs(neighborOutlines{j}(:,2)-40),'y')
        end    
        xlim([1 40])
        ylim([1 40])  
        

        % plot trace
        subplot(3,2,[5:6])
        hold off
        plot(1:length(traceCutout),traceCutout,'k')
        hold on
        plot(i,traceCutout(i),'or')
        xlabel('Time (s)')
        ylabel('\Delta F / F')
        % TODO get measures right
        set(gca, 'XTick', [], 'YTick', [])

        pause(waitTime);
    end
    close(f)


end