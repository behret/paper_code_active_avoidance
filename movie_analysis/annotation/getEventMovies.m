function [movieCutouts, traceCutouts, cellOutlines, neighborOutlines] = getEventMovies(movie, traces, filters, events)
% get event movies for all events of all cells

    [ areas,centroids,cvxHulls,cvxAreas,outlines ] = getFilterProps( filters );

    windowSpace = 20;
    windowTime = 20;
    
    for c = 1:length(events)
        
        % define borders in space (same for all events)
        thisCentroid = centroids(c,:);
        xLow  = round(max(thisCentroid(2) - (windowSpace-1),1));
        xHigh = min(xLow + 2*windowSpace-1,size(movie,1));
        if length(xLow:xHigh) ~= 2*windowSpace
            xLow = size(movie,1) - (2*windowSpace-1);
        end
        yLow  = round(max(thisCentroid(1) - (windowSpace-1),1));
        yHigh = min(yLow + 2*windowSpace-1,size(movie,2));
        if length(yLow:yHigh) ~= 2*windowSpace
            yLow = size(movie,2) - (2*windowSpace-1);
        end        
        
        % get convex hull of the cell and its immediate neighbors (same for all events)
        thisOutline = outlines{c};
        cDist = abs(round(bsxfun(@minus,centroids,thisCentroid))); 
        cDist(c,1) = inf; % exculde current cell
        neighborOutlines{c} = outlines(cDist(:,1) < 20 & cDist(:,2) < 20);
        offset = [yLow xLow];
        neighborOutlines{c} = cellfun(@(x) bsxfun(@minus,x,offset),neighborOutlines{c},'UniformOutput', false);
        cellOutlines{c} =  bsxfun(@minus,thisOutline,offset);
        
        for e = 1:length(events{c})
            
            % define borders in time
            zLow  = max(events{c}(e) - (windowTime-1),1);
            zHigh = min(events{c}(e) + windowTime,size(movie,3)); 

            % get cutouts of trace and movie
            mov = movie(xLow:xHigh,yLow:yHigh,zLow:zHigh);
            % reduce precision and downsample to save space
            mov = uint8(mat2gray(mov)*255);
            mov = imresize(mov,.5);  
            movieCutouts{c}{e} = mov;
            traceCutouts{c}{e} = traces(c,zLow:zHigh);

        end
    end
        
end