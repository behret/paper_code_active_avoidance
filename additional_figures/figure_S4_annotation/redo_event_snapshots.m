        % recreate snapshots in rectengular format

        clear
        sub = 11;
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

        for ses = 1:p.nSessions
            ses
            tic
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
                    events{c} = cat(2,events{c},sesEvents{c}+batchBorders(ses));
                end
            end
            toc
        end
        
        %%
        
        snapshotCollections = cell(size(traces,1),1);

        for i = 1:size(traces,1)
            % sort everything according to peak height
            [~,sortIdx] = sort(traces(i,events{i}),'descend');
            if ~isempty(events{i})
                eventSnapshotsSrt{i} = eventSnapshots{i}([1 sortIdx+1]); % first one is filter
            end

            % put snapshots into one image
            sideLen = ceil(sqrt(length(eventSnapshotsSrt{i})));            
            height = floor(sideLen/2);
            width = height * 4;
            while width * height < length(eventSnapshotsSrt{i})
                width = width+1;
            end
            
            snapshotSquare = cell(width,height);
            for j=1:numel(snapshotSquare)
                if j <= length(eventSnapshotsSrt{i})
                    snapshotSquare{j} = eventSnapshotsSrt{i}{j};
                else
                    snapshotSquare{j} = zeros(size(eventSnapshotsSrt{i}{1}),'single');
                end
            end       
            snapshotCollections{i} = cell2mat(snapshotSquare)';
        end 
        
        %% save
        
        fpath = 'G:\SRM_results\one_subspace_task_decoding\event_snapshots_for_annotation_fig';
        save(fpath,'snapshotCollections','eventSnapshots','events')
        
        