function [ output_args ] = runSignalExtraction( p )
% runs extraction for every subject and session
   
    % loop through subjects and sessions
    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            disp([char(datetime('now')) ' Starting signal extraction for Mouse ' num2str(sub) '/' num2str(p.nSubjects) ', Session ' num2str(ses)])            
            
            % set paths
            thisSub = p.subjects(sub);
            moviePath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],['session' num2str(ses)],'preprocessed','preprocessedMovie.h5');
            saveDir = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],['session' num2str(ses)],'extracted');
            
            if ~exist(moviePath) || exist(fullfile(saveDir,'resultsPCAICA.mat'))
                disp('skipping sesssion')
                continue
            end
            
            % run extraction 
            tic
            extractSignals(p,moviePath,saveDir)
            t = toc;
            disp([char(datetime('now')) ' Finished signal extraction for Mouse ' num2str(sub) '/' num2str(p.nSubjects) ', Session ' num2str(ses) ' in ' num2str(t/60) ' minutes'])
        end
    end
end