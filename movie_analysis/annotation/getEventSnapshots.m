function [ eventSnapshots ] = getEventSnapshots(events, traces, movie, filters)

    [ areas,centroids,cvxHulls,cvxAreas,outlines ] = getFilterProps( filters );

    % loop through cells
    for i = 1:length(events)

        if ~isempty(events{i})
            w=15;
            centroids(i,1)=min(centroids(i,1),size(movie,2));
            centroids(i,2)=min(centroids(i,2),size(movie,1));
            xLims=max(1,round(centroids(i,1)-w)):min(size(movie,2), round(centroids(i,1)+w));
            yLims=max(1,round(centroids(i,2)-w)):min(size(movie,1), round(centroids(i,2)+w));
            centroids(i,1)=min(round(centroids(i,1))-min(xLims)+1,length(xLims));
            centroids(i,2)=min(round(centroids(i,2))-min(yLims)+1,length(yLims));

            eventImages=movie(:,:,events{i});
            eventImages=eventImages(yLims,xLims,:);

            imgCell=cell(length(events{i})+1,1);
            minVal=min(eventImages(:));
            maxVal=max(eventImages(:));
            for j=1:numel(imgCell)
                if j==1
                    imgCell{j}=single(filters(yLims, xLims,i)+1);
                    imgCell{j}=(imgCell{j}-min(imgCell{j}(:)));
                    imgCell{j}=imgCell{j}/max(imgCell{j}(:))*max(eventImages(:)-minVal)+minVal;
                    imgCell{j}(centroids(i,2), centroids(i,1))=minVal;
                elseif j-1<=length(events{i})
                    imgCell{j}=single(eventImages(:,:,j-1));
                    imgCell{j}(centroids(i,2), centroids(i,1))=minVal;
                else
                    if maxVal>1
                        imgCell{j}=ones(size(eventImages(:,:,1)), 'single');
                    else
                        imgCell{j}=zeros(size(eventImages(:,:,1)), 'single');
                    end
                end
            end
            eventSnapshots{i}=imgCell;

        else
            eventSnapshots{i}={};
        end
    end
end


