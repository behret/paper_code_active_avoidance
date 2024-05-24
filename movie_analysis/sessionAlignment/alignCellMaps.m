function [ mapsAligned, tforms ] = alignCellMaps(p, maps )


    %% get tforms of coarse pre-alignment, if there exists one 
    % has to be manually generated. this only makes sense if the automatic 
    % alignment fails due to large differences in the original cell maps

    for sub = 1:p.nSubjects
        thisSub = p.subjects(sub);
        fpath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment','coarseAlignment.mat');

        if exist(fpath,'file')
            load(fpath)
            for ses = 1:p.nSessions
                if  ~isempty(coarseAlignment{ses})
                    tforms_coarse{sub,ses} = affine2d(coarseAlignment{ses}');
                else
                    tforms_coarse{sub,ses} = affine2d(eye(3));
                end
            end
        else
            for ses = 1:p.nSessions
                tforms_coarse{sub,ses} = affine2d(eye(3));
            end
        end
    end


    %% align with imreg, using coarse tforms as initial transformations

    % set params of registration procedure
    [optimizer,metric] = imregconfig('multimodal');
    metric.NumberOfHistogramBins = 100;
    metric.NumberOfSpatialSamples = 2000; % 1000
    optimizer.MaximumIterations = 2000; % 1000
    optimizer.InitialRadius = optimizer.InitialRadius/(3.5)^2; % 3.5

    for sub = 1:p.nSubjects
        disp(['Aligning subject ' num2str(sub) ' of ' num2str(p.nSubjects)]); 
        thisSub = p.subjects(sub);
        for ses = 1:p.nSessions
            
            % if there is already a veridied tform, load and continue 
            savePath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment',['registrationCoords_Session' num2str(ses) '.mat']);
            if exist(savePath) && any(p.subjects(sub) == p.alignment.verifiedSubjects)
                load(savePath)
                tforms{sub,ses} = tform;
                disp(['Using verified alignment for subject ' num2str(thisSub)]); 
                continue
            end
            
            % do initial transformation on ref day map
            fixed = imwarp(maps{sub,p.alignment.refDay},tforms_coarse{sub,p.alignment.refDay},'OutputView',imref2d(size(maps{sub,ses}))); 
            % get final transformation by aligning fixed and moving with coarse
            % transformation as starting point
            moving = maps{sub,ses};
            tforms{sub,ses} = imregtform(moving, fixed, 'similarity', optimizer, metric,'InitialTransformation',tforms_coarse{sub,ses});
        end
    end


    %% validate all aligned maps by applying the final tform to the original maps 

    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            mapsAligned{sub,ses} = imwarp(maps{sub,ses},tforms{sub,ses},'OutputView',imref2d(size(maps{sub,ses})));
        end
    end

    verfiedIdx = [];
    % display validated cell maps
    if ~isempty(p.alignment.verifiedSubjects)
        verifiedAlignments = mapsAligned';
        for i = p.alignment.verifiedSubjects
            verfiedIdx = [verfiedIdx find(p.subjects == i)];
        end
        imtool3D(cat(3,verifiedAlignments{:,verfiedIdx}))
    end
    
    % display unvalidataed cell maps
    notVerified = setdiff(1:p.nSubjects,verfiedIdx);
    if ~isempty(notVerified)
        newAlignments = mapsAligned';
        imtool3D(cat(3,newAlignments{:,notVerified}))
    end
end