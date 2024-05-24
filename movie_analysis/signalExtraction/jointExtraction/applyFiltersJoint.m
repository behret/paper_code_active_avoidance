function [ output_args ] = applyFiltersJoint( p,thisSub )
% uses spatial filters from joint extraction to obtain dfof traces for
% every session 

    %% load data (filters from joint extraction and movie concat data)
    savePath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','extracted','dfof_traces.mat');
    if exist(savePath)
        disp('Skipping subject (already done)')
        return
    end
    filtersPath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','extracted','resultsPCAICA.mat');
    load(filtersPath,'filters')
    % flatten pixel dimension
    [height,width,nFilters] = size(filters);
    filters = reshape(filters,height * width, nFilters);
    
    % set paths for session data   
    for ses = 1:p.nSessions
        movPaths{ses} = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'preprocessed','preprocessedMovie.h5');
        regPaths{ses} = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment',['registrationCoords_Session' num2str(ses) '.mat']);
        info = h5info(movPaths{ses});
        nFrames = info.Datasets.Dataspace.Size(3);
        movieLengths(ses) = nFrames;
    end
    
    %% process movies step by step
    for ses = 1:p.nSessions
                
        % load movie
        disp([char(datetime('now')) ' processing movie ' num2str(ses) ' of ' num2str(p.nSessions)])
        movie = prepareBatch(p,movPaths{ses},regPaths{ses},0);
        [height, width, num_frames] = size(movie);
        movie = reshape(movie, height * width, num_frames);

        % use filters to get temporal traces
        traces{ses} = (movie' * filters)';
        clear movie
        
        % if the session has to be excluded due to improper alignment,
        % replace traces with nans
        sub = find(p.subjects == thisSub);
        if any(p.alignment.exclude{sub} == ses)
            traces{ses}(:) = nan;
        end  
    end

    %% save results
    % concat traces to have same format as regular joint extraction
    traces = cat(2,traces{:});
    save(savePath,'p','traces')
end



