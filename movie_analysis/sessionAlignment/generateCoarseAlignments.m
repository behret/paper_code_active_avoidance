%% this script can be used to generate coarse alignment coordinates
% we do this if the automatic alignment fails because there are
% large scale rotations or translations

%% load maps
p = params_2DAA;
thisSub = 8;

for ses = 1:p.nSessions
    fpath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'extracted','cellMap.mat');
    load(fpath)
    maps{ses} = cellMap;
end


%% go through sessions and note down necessary alignments below

imtool3D(cat(3,maps{:}))

%% restrict to ref day and problematic days
imtool3D(cat(3,maps{[6,11]}))


%% 
% first coordinate: + is right, - is left (wrt imtool3D)
% second coordinate: + is down, - is up (wrt imtool3D)

coarseAlignment = cell(p.nSessions);

% 
rl = 5;
ud = 0;
phi = 0;
coarseAlignment{10} = [cos(phi) -sin(phi) rl;sin(phi) cos(phi) ud;0 0 1];


rl = 0;
ud = 10;
phi = deg2rad(-1.5);
coarseAlignment{11} = [cos(phi) -sin(phi) rl;sin(phi) cos(phi) ud;0 0 1];



%% inspect adjusted maps, which should be roughly aligned now

for i = 1:p.nSessions   
    if ~isempty(coarseAlignment{i})
        tform = affine2d(coarseAlignment{i}');
        maps{i} = imwarp(maps{i},tform,'OutputView',imref2d(size(maps{i})));
    end
end

imtool3D(cat(3,maps{:}))



%% save
savePath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment','coarseAlignment.mat');
save(savePath,'coarseAlignment')









