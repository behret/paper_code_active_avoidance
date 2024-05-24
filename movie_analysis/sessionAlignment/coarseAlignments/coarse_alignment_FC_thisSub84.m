%% this script can be used to generate coarse alignment coordinates
% we do this if the automatic alignment fails because there are
% large scale rotations or translations

%% load maps
p = params_FC;

%SUBJECT WAS EXCLUDED!
sub = 0; % thisSub = 84
for ses = 1:p.nSessions
    thisSub = p.subjects(sub);
    fpath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'extracted','cellMap.mat');
    load(fpath)
    maps{ses} = cellMap;
end


%% go through sessions and note down necessary alignments below

imtool3D(cat(3,maps{:}))

%% restrict to ref day and problematic days
imtool3D(cat(3,maps{[1,2,4]}))


%% 
% first coordinate: + is right, - is left (wrt imtool3D)
% second coordinate: + is down, - is up (wrt imtool3D)

coarseAlignment = cell(p.nSessions);

% 
rl = 75;
ud = -50;
phi = .08;
coarseAlignment{1} = [cos(phi) -sin(phi) rl;sin(phi) cos(phi) ud;0 0 1];

rl = 60;
ud = -30;
phi = .08;
coarseAlignment{2} = [cos(phi) -sin(phi) rl;sin(phi) cos(phi) ud;0 0 1];

rl = -20;
ud = 0;
phi = 0;
coarseAlignment{4} = [cos(phi) -sin(phi) rl;sin(phi) cos(phi) ud;0 0 1];

rl = 0;
ud = -20;
phi = 0;
coarseAlignment{6} = [cos(phi) -sin(phi) rl;sin(phi) cos(phi) ud;0 0 1];

%% inspect adjusted maps, which should be roughly aligned now
maps_new = cell(p.nSessions);
for i = 1:p.nSessions   
    if ~isempty(coarseAlignment{i})
        tform = affine2d(coarseAlignment{i}');
        maps_new{i} = imwarp(maps{i},tform,'OutputView',imref2d(size(maps{i})));
    else
        maps_new{i} = maps{i};
    end
end

imtool3D(cat(3,maps_new{:}))



%% save
savePath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment','coarseAlignment.mat');
save(savePath,'coarseAlignment')









