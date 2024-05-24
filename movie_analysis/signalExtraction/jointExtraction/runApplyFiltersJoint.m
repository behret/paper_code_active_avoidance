function [ output_args ] = runApplyFiltersJoint( p )
% joint extraction was run already, here we only apply warping,
% normalization etc. to the session videos and use the spation filters to
% obtain the temporal traces

    for sub = 1:p.nSubjects
        disp([char(datetime('now')) ' Starting applyFiltersJoint for Mouse ' num2str(sub) '/' num2str(p.nSubjects)])            
        tic
        thisSub = p.subjects(sub);
        applyFiltersJoint(p,thisSub);
        t = toc;
        disp([char(datetime('now')) ' Finished applyFiltersJoint for Mouse ' num2str(sub) '/' num2str(p.nSubjects) ' in ' num2str(t/60) ' minutes'])            
    end

end