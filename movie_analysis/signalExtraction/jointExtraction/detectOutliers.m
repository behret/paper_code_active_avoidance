function outliers = detectOutliers(p)
% first detect and remove outliers:
% sometimes broken frames cause high variance signals, these can be
% detected via the variance over all cells


    if strcmp(p.experimentName,'2DAA')
       var_thresh = .07;
    elseif strcmp(p.experimentName,'2TAA')
       var_thresh = .08;
    else % FC
       var_thresh = .08;
    end

    inspect_full_ses = 0; % used in debugging mode to look at entire ses
    allTraces = {};
    outliers = [];
    for sub = 1:p.nSubjects
        % load data
        thisSub = p.subjects(sub);
        % load traces, filters
        fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','dfof_traces.mat');
        load(fpath,'traces');

        % get movie lengths to be able to split up sessions
        movieLengths = zeros(1,p.nSessions);
        for ses = 1:p.nSessions
            movPath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'preprocessed','preprocessedMovie.h5');
            info = h5info(movPath);
            nFrames = info.Datasets.Dataspace.Size(3);
            movieLengths(ses) = nFrames;
        end
        batchBorders = [0 cumsum(movieLengths)];

        % find outliers via variance
        % first we need to normalize sessions (similar as below but per
        % cell, which might cause problems below, but doenst matter here)
        ses_normed = traces;
        for ses = 1:p.nSessions
            % cut traces into sessions
            sesTraces = traces(:,batchBorders(ses)+1:batchBorders(ses+1));
            for ce = 1:size(sesTraces,1)
                ses_normed(ce,batchBorders(ses)+1:batchBorders(ses+1)) = mat2gray(sesTraces(ce,:));
            end
        end
        var_per_t = var(ses_normed);
        
        if inspect_full_ses == 1
            figure,plot(var_per_t)
        else
            % look at suspicious time steps 
            % these are listed in outliers and have to be validated
            check_t = find(var_per_t > var_thresh);
            for i = 1:length(check_t)
                outliers = cat(1,outliers,[sub check_t(i)]);
                figure
                win = max(1,check_t(i)-50) : min(size(traces,2),check_t(i)+50);
                imagesc(traces(:,win))
                title(['Sub:' num2str(sub), ' frame:' num2str(check_t(i))])
            end
        end
    end
end

