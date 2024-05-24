function get_heuristic_sorting(p)
% heurisitc approach for automatic annotation: we sort cells by various 
% criteria and generate a sorting which reflects the 'quality' of the
% different extracted cells

    for sub = 1:p.nSubjects
        tic
        thisSub = p.subjects(sub);

        % load event data
        fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','eventData');
        load(fpath,'events','eventSnapshots')

        % load filters
        fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','resultsPCAICA');
        load(fpath,'filters')


        %% original sorting
        scoreMat = [];
        scoreMat = cat(1,scoreMat,1:length(events));

        % %% number of events (more events is better)
        % 
        % numEvents = cellfun(@(x) length(x),events);
        % [~,sortIdx] = sort(numEvents,'descend');
        % sortMat = cat(1,sortMat,sortIdx');
        % 
        % 
        % %% difference from median area 
        % 
        % [ areas,centroids,cvxHulls,cvxAreas,outlines ] = getFilterProps( filters );
        % [~,sortIdx] = sort(abs(areas - median(areas)),'ascend');
        % sortMat = cat(1,sortMat,sortIdx);


        %% snapshot similariry
        errors = {};
        for c = 1:length(eventSnapshots)
            if ~isempty(eventSnapshots{c})
                filIm = mat2gray(eventSnapshots{c}{1});
                for e = 1:length(eventSnapshots{c})-1
                    errors{c}(e) = immse(filIm,mat2gray(eventSnapshots{c}{e+1}));
                end
            else
                errors{c} = inf;
            end
        end

        cellError = cellfun(@(x) mean(x),errors);
        [~,sortIdx] = sort(cellError,'ascend');
        % score is the rank of a cell when sorted according to snapshot similarity
        [~,score] = sort(sortIdx);  
        scoreMat = cat(1,scoreMat,2*score);


        %% get final idx
        [~,heuristic_sorting] = sort(sum(scoreMat),'ascend');


        %%
        savePath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','heuristic_sorting');
        save(savePath,'heuristic_sorting')
        t = toc;
        disp([char(datetime('now')) ' Got heuristic sorting for Mouse ' num2str(sub) '/' num2str(p.nSubjects) ' in ' num2str(t/60) ' minutes'])            
    end

end
