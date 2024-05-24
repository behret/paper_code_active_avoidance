function detect_split_cells(p)
    % we detect split cells via temporal correlation and spatial proximity
    % we do this after annotation and save the classification
    % this is later used in the data organization step to exclude cells 

    %% load filters and traces and apply selection from annotation
    for sub = 1:p.nSubjects
        sub
        thisSub = p.subjects(sub);

        % load data
        fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','norm_traces.mat');
        load(fpath,'traces')
        fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','resultsPCAICA.mat');
        load(fpath,'filters')
        % get movie lengths to be able to split up sessions
        movieLengths = zeros(1,p.nSessions);
        for ses = 1:p.nSessions
            movPath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'preprocessed','preprocessedMovie.h5');
            info = h5info(movPath);
            nFrames = info.Datasets.Dataspace.Size(3);
            movieLengths(ses) = nFrames;
        end

        % if annotation exists, restrict traces to verified cells
        fpath_annotation = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','PCAICAsorted.mat');
        fpath_heuristic = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','heuristic_sorting.mat');
        if exist(fpath_annotation)
            if exist(fpath_heuristic)
                % annotation was done in the orded specified by the
                % heuristic sorting -> to select the right cells we first
                % need to sort and then select cells
                load(fpath_heuristic,'heuristic_sorting')
                traces = traces(heuristic_sorting,:);
                filters = filters(:,:,heuristic_sorting);
            end
            load(fpath_annotation,'valid')
            traces = traces(valid == 1,:);
            filters = filters(:,:,valid == 1);
        elseif exist(fpath_heuristic)
            disp(['Using heuristic sorting for subject ' num2str(thisSub) '. Selecting first 300 cells.'])
            load(fpath_heuristic,'heuristic_sorting')
            traces = traces(heuristic_sorting(1:300),:);
            filters = filters(:,:,heuristic_sorting(1:300));
        else
            disp(['No annotation found for subject ' num2str(thisSub) '. Selecting first 300 cells.'])
            traces = traces(1:300,:);
            filters = filters(:,:,1:300);
        end

        % split into sessions
        sessionStart = 1;
        for ses = 1:p.nSessions
            allTraces{sub,ses} = single(traces(:,sessionStart:sessionStart+movieLengths(ses)-1));
            sessionStart = sessionStart+movieLengths(ses);
        end
        allFilters{sub} = filters;
    end

    traces = allTraces;
    filters = allFilters;
    
    %% check for split cells 
    disp_splits = 0;
    all_excl = {};
    for sub = 1:p.nSubjects
        sub
        thisSub = p.subjects(sub);

        sessions = setdiff(1:p.nSessions,p.alignment.exclude{sub});
        fulltr = cat(2,traces{sub,sessions});
        fulltr(isnan(fulltr)) = 0;
        cmat = corrcoef(fulltr');
        cmat = tril(cmat,-1); % remove upper half and diag

        [ areas,centroids,cvxHulls,cvxAreas,outlines ] = getFilterProps(filters{sub});
        cDist = zeros(size(fulltr,1));
        for i = 1:size(centroids,1)
            for j = i+1:size(centroids,1)
                cDist(j,i) = sqrt((centroids(i,1) - centroids(j,1))^2 + (centroids(i,2) - centroids(j,2))^2);
            end
        end
        %figure,scatter(cDist(:),cmat(:),'.')

        split_inds = cmat>.7 & cmat<1 & cDist<20 & cDist>0;
        [x,y] = ind2sub(size(cmat),find(split_inds));

        if disp_splits
            for i = 1:length(x)
                figure('Position',[100 100 1000 300])
                subplot(1,2,1)
                hold on
                plot(fulltr(x(i),1000:2000))
                plot(fulltr(y(i),1000:2000))
                title(num2str(cDist(x(i),y(i))))
                xlim([1 1000])

                subplot(1,2,2)
                fs = [];
                fs = cat(3,fs,filters{sub}(:,:,x(i))); 
                fs = cat(3,fs,filters{sub}(:,:,y(i))); 
                imagesc(max(fs,[],3))
            end 
        end
 
        % as a heuristic we use the sorting to determine which signal is
        % likely better. Should merge cells at some point
        excl_idx = max([x,y]');
        excl_idx = unique(excl_idx);

        % save
        fpath_excl = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','split_detection.mat');
        save(fpath_excl,'excl_idx')
        all_excl{sub} = excl_idx;
    end
    cellfun(@(x) length(x),all_excl)
    
end