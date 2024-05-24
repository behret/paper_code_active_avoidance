function [ output_args ] = prepareAnnotation(p)
% loads extraction results and starts cell checker
    
    for sub = 1:p.nSubjects
        tic
        thisSub = p.subjects(sub);

        %% load data
        % load traces, filters
        fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','norm_traces.mat');
        load(fpath,'traces');

        fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','resultsPCAICA.mat');
        load(fpath,'filters');

        % recreate movie concat data
        movieLengths = zeros(1,p.nSessions);
        for i = 1:p.nSessions
            movPaths{i} = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(i)],'preprocessed','preprocessedMovie.h5');
            regPaths{i} = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment',['registrationCoords_Session' num2str(i) '.mat']);
            info = h5info(movPaths{i});
            nFrames = info.Datasets.Dataspace.Size(3);
            movieLengths(i) = nFrames;
        end
        batchBorders = [0 cumsum(movieLengths)];

        saveDir = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted');


        %% loop through sessions to collect event data

        events = cell(size(traces,1),1);
        eventSnapshots = cell(size(traces,1),1);
        eventMovies = cell(size(traces,1),1);
        eventTraces = cell(size(traces,1),1);

        for ses = 1:p.nSessions
            if any(p.alignment.exclude{sub} == ses)
                continue
            end
            
            % cut traces into sessions and get ses events
            sesTraces = traces(:,batchBorders(ses)+1:batchBorders(ses+1));
            sesEvents = getPeaks(p,double(sesTraces));

            % load session movie
            sesMovie = prepareBatch(p,movPaths{ses},regPaths{ses},0);

            % get event snapshots
            shots = getEventSnapshots(sesEvents, sesTraces, sesMovie, filters);

            % get event movies
            [movieCutouts, traceCutouts, cellOutlines, neighborOutlines] = getEventMovies(sesMovie, sesTraces, filters, sesEvents); 

            % for every cell, collect snapshots, movies and traces over 
            % all sessions. hulls stay the same
            for c = 1:size(sesEvents,2)
                % the first entry is always the filter, but we only need it
                % once at the beginning
                if ~isempty(sesEvents{c})
                    if isempty(eventSnapshots{c})
                        eventSnapshots{c} = cat(1,eventSnapshots{c},shots{c});
                    else
                        eventSnapshots{c} = cat(1,eventSnapshots{c},shots{c}(2:end));
                    end

                    eventMovies{c} = cat(2,eventMovies{c},movieCutouts{c});
                    eventTraces{c} = cat(2,eventTraces{c},traceCutouts{c});
                    events{c} = cat(2,events{c},sesEvents{c}+batchBorders(ses));
                end
            end
        end

        %% sort events and put snapshots into square frame

        snapshotCollections = cell(size(traces,1),1);

        for i = 1:size(traces,1)

            % sort everything according to peak height
            [~,sortIdx] = sort(traces(i,events{i}),'descend');
            if ~isempty(events{i})
                eventSnapshots{i} = eventSnapshots{i}([1 sortIdx+1]); % first one is filter
                eventMovies{i} = eventMovies{i}(sortIdx);
                eventTraces{i} = eventTraces{i}(sortIdx);
            end

            % put snapshots into one image
            sideLen = ceil(sqrt(length(eventSnapshots{i})));
            snapshotSquare = cell(sideLen);
            for j=1:numel(snapshotSquare)
                if j <= length(eventSnapshots{i})
                    snapshotSquare{j} = eventSnapshots{i}{j};
                else
                    snapshotSquare{j} = zeros(size(eventSnapshots{i}{1}),'single');
                end
            end       
            snapshotCollections{i} = cell2mat(snapshotSquare);

        end 

        %% save

        save(fullfile(saveDir,'eventData'),'events','snapshotCollections','eventMovies','eventTraces','cellOutlines','neighborOutlines','eventSnapshots','-v7.3')


        %% check whether concat events and all events are the same

        %allEvents = getPeaks(p,double(traces));
        %scatter(cellfun(@(x) length(x),allEvents),cellfun(@(x) length(x),events))

        %%
        t = toc;
        disp([char(datetime('now')) ' Finished preparing annotation for Mouse ' num2str(sub) '/' num2str(p.nSubjects) ' in ' num2str(t/60) ' minutes'])            

    end
end

