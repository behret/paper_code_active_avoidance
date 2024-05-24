%% this script can be used to generate coarse alignment coordinates
% we do this if the automatic alignment fails because there are
% large scale rotations or translations

%% load maps
clear
p = params_2DAA;
sub = 4;

for ses = 1:p.nSessions
    thisSub = p.subjects(sub);
    fpath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'extracted','cellMap.mat');
    load(fpath)
    maps{ses} = cellMap;
end


%% go through sessions and note down necessary alignments below

imtool3D(cat(3,maps{:}))

%% restrict to ref day and problematic days
imtool3D(cat(3,maps{[5,10,11]}))


%% 
% first coordinate: + is right, - is left (wrt imtool3D)
% second coordinate: + is down, - is up (wrt imtool3D)

coarseAlignment = cell(1,p.nSessions);

rl = 16;
ud = 15;
phi = 0.06;
coarseAlignment{10} = [cos(phi) -sin(phi) rl;sin(phi) cos(phi) ud;0 0 1];


rl = -7;
ud = 35;
phi = 0.0;
coarseAlignment{11} = [cos(phi) -sin(phi) rl;sin(phi) cos(phi) ud;0 0 1];


%% inspect adjusted maps, which should be roughly aligned now
maps_new = cell(1,p.nSessions);
for i = 1:p.nSessions   
    if ~isempty(coarseAlignment{i})
        tform = affine2d(coarseAlignment{i}');
        maps_new{i} = imwarp(maps{i},tform,'OutputView',imref2d(size(maps{i})));
    else
        maps_new{i} = maps{i};
    end
end

imtool3D(cat(3,maps_new{[5,10,11]}))



%% save
savePath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment','coarseAlignment.mat');
save(savePath,'coarseAlignment')









