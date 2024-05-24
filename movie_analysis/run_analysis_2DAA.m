%% Example run for jointly analyzing two sessions from one subject
% go through the sections step by step

%% set general parameters and create folder structure 

% create structure p, which holds all parameters. Parameters are 
% initialized as set in params.m, some of them are overwritten in this script 
clear
p = params_2DAA;
p.numWorkers = 6;
createFolderStructure(p)

%% run preprocessing and signal extraction
runPreprocessing(p) % around 1.5 to 2 hours per session
runSignalExtraction(p) % around 20 minutes per session
runAlignment(p)

%% inspect bleaching components
for sub = 1:p.nSubjects
    thisSub = p.subjects(sub);
    figure
    for ses = 1:p.nSessions
        fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],['session' num2str(ses)],'preprocessed','preprocessing_data.mat');
        load(fpath)
        subplot(2,p.nSessions,ses)
        imagesc(bleach_filters(:,:,1))
        subplot(2,p.nSessions,ses+p.nSessions)
        imagesc(bleach_filters(:,:,2))
    end
end

%% align cell maps
% run this section and verify that the alignment that is displayed is
% correct 
clear
p = params_2DAA;
p.alignment.refDay = 5;
runAlignment(p)
 
%% run joint extraction (approx)
clear
p = params_2DAA;
runJointExtraction(p) % ~1.5h per subject
runApplyFiltersJoint(p)

%% inspect cell maps: compare joint cell map and session cell map
for sub = 1:p.nSubjects
    thisSub = p.subjects(sub);
    load(fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','alignment','alignedCellMaps.mat'));
    load(fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','cellmap.mat'));
    imtool3D(cat(3,mapsCropped,cellMap))
end

%% post processing: remove outliers (validate) 
outliers = detectOutliers(p);

% note down outliers validated through plots created by detectOutliers
validated = [5 7 10 11 12 13];
outliers = outliers(validated,:);
% add additional outliers (sometimes the timestep next to the detected 
% outlier is also corrupted but is not caught by the threshold)

additional_outliers(1,:) = [5 108899];
additional_outliers(2,:) = [5 88896];
outliers = cat(1,outliers,additional_outliers);

%% post processing: normalize traces 
normalizeTraces(p,outliers);

%% post processing: prepare annotation
prepareAnnotation(p);
get_heuristic_sorting(p)

%% do annotation
% todo: 
% done: 2 3 5 6 7 8 9 10 11 12 13 14
clear
p = params_2DAA;
thisSub = 14;
valid = annotationTool( p,thisSub );
sum(valid)

