function [ output_args ] = normalizeTraces(p,outliers)
% normalize dfof traces from joint extraction
% different sessions might have different signal to noise ratios, thus
% sessions should be normalized individually as follows:
% estimate SNR differences between sessions by calculating the std of
% cells in different sessions, then take mean over cells.

% for this to work we need to crop outliers first as they might corrupt the
% ranges

    %% load data
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
        
        bbs{sub} = batchBorders;
        allTraces{sub} = traces;
    end
    
    %% remove validated outliers
    for i = 1:size(outliers,1)
        sub = outliers(i,1);
        t = outliers(i,2);
        allTraces{sub}(:,t) = nan;
    end
    
    %% calculate norm factor
    factors = [];
    for sub = 1:p.nSubjects
        batchBorders = bbs{sub};
        cell_stds = [];
        for ses = 1:p.nSessions
            % cut traces into sessions
            sesTraces = allTraces{sub}(:,batchBorders(ses)+1:batchBorders(ses+1));
            cell_stds(ses,:) = nanstd(sesTraces,[],2)';
        end
        
        [~,min_ses] =  min(mean(cell_stds'));
        
        rel_stds = cell_stds;
        for ses = 1:p.nSessions
            rel_stds(ses,:) = cell_stds(ses,:) ./ cell_stds(min_ses,:);
        end
        
        factors(sub,:) = 1./mean(rel_stds,2)';
        
                
        % apply factor per session
        traces_ses_norm = allTraces{sub};
        for ses = 1:p.nSessions
            % cut traces into sessions
            sesTraces = allTraces{sub}(:,batchBorders(ses)+1:batchBorders(ses+1));
            traces_ses_norm(:,batchBorders(ses)+1:batchBorders(ses+1)) = sesTraces * factors(sub,ses);
        end

        normTraces{sub} = traces_ses_norm;
        
        
        figure
        subplot(1,2,1)
        plot(var(allTraces{sub}))
        subplot(1,2,2)
        plot(var(traces_ses_norm))   
    end
        
    %% save per subject
    for sub = 1:p.nSubjects
        traces = normTraces{sub};
        thisSub = p.subjects(sub);
        fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','norm_traces.mat');
        save(fpath,'traces');
    end

end

