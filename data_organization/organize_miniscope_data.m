function organize_miniscope_data(p)
    % organization of miniscope data for all experiments
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

    %% exclude cells that were classified as splits
    for sub = 1:p.nSubjects
        % load exlusion index
        thisSub = p.subjects(sub);
        fpath_excl = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','split_detection.mat');
        load(fpath_excl,'excl_idx')
        for ses = 1:p.nSessions
            traces{sub,ses}(excl_idx,:) = [];
        end
        filters{sub}(:,:,excl_idx) = [];
    end
    
    %% make sessions that were not properly aligned nan
    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            if any(p.alignment.exclude{sub} == ses)
                traces{sub,ses} = zeros(size(traces{sub,ses}))/0;
            end
        end
    end
    
    %% save
    save_path = fullfile(p.rootDir,'results','traces');
    save(save_path,'traces','-v7.3')
    save_path = fullfile(p.rootDir,'results','filters');
    save(save_path,'filters','-v7.3')

end