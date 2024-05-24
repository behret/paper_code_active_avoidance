function [ output_args ] = runAlignment( p )
%ALIGNJOINT aligns cell maps of all sessions for each subject and saves
%registration tform

    %% load maps

    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            thisSub = p.subjects(sub);
            fpath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'extracted','cellMap.mat');
            load(fpath)
            maps{sub,ses} = cellMap;
        end
    end

    %% run alignment

    [ mapsAligned, tforms ] = alignCellMaps(p, maps );


    %% for every subject: get crop coordinates and save with tforms for all sessions; save aligned maps

    for sub = 1:p.nSubjects
        thisSub = p.subjects(sub);
        
        % get crop coords
        maps = cat(3,mapsAligned{sub,:});
        zeroMask = squeeze(max(maps == 0,[],3));
        [N, S, W, E] = getCropCoords(zeroMask);        
        
        % save together with tforms
        for ses = 1:p.nSessions
            tform = tforms{sub,ses};
            savePath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment',['registrationCoords_Session' num2str(ses) '.mat']);
            save(savePath,'tform','N','S','W','E')
        end

        % save alinged maps for visualization
        mapsCropped = maps(N:S,W:E,:);
        savePath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment','alignedCellMaps');
        save(savePath,'maps','mapsCropped');
    end
    
    


end

