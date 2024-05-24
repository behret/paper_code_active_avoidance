function [ output_args ] = runJointExtraction( p )
%RUNJOINTEXTRACTIOMN runs joint extraction for every subject

    for sub = 1:p.nSubjects
        disp([char(datetime('now')) ' Starting joint extraction for Mouse ' num2str(sub) '/' num2str(p.nSubjects)])            
        tic
        thisSub = p.subjects(sub);
        extractJoint(p,thisSub);
        t = toc;
        disp([char(datetime('now')) ' Finished joint extraction for Mouse ' num2str(sub) '/' num2str(p.nSubjects) ' in ' num2str(t/60) ' minutes'])            
    end

