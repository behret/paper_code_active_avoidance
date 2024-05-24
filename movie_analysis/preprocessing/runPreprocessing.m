function [ output_args ] = runPreprocessing( p )
%RUNPREPROCESSING runs preprocessing for all subjects and sessions

    % loop through subjects and sessions
    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            disp([char(datetime('now')) ' Starting preprocessing for Mouse ' num2str(sub) '/' num2str(p.nSubjects) ', Session ' num2str(ses)])           
                        
            % set paths
            thisSub = p.subjects(sub);
            moviePath = fullfile(p.rawDataRootDir,['M' num2str(thisSub)],['session' num2str(ses)],'rawMovie.h5');
            saveDir = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],['session' num2str(ses)],'preprocessed');
            if ~exist(saveDir)
                mkdir(saveDir)
            end
            
            % if there is no raw movie or the preprocessed movie is already
            % there, skip the session
            if ~exist(moviePath) || exist(fullfile(saveDir,'preprocessedMovie.h5'))
                disp('skipping sesssion')
                continue
            end
            
            %run
            tic
            preprocessMovie(p,moviePath,saveDir)
            t = toc;
            disp([char(datetime('now')) ' Finished preprocessing for Mouse ' num2str(sub) '/' num2str(p.nSubjects) ', Session ' num2str(ses) ' in ' num2str(t/60) ' minutes'])
        end
    end
end

