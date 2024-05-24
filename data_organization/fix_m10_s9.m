
%% issue:
% miniscope and behavior recordings are too long
% probably due to trigger issue
% miniscope is longer than behavior
% what probably happend: 
% - miniscope was running before exeriment started
% - bcam recorded frames when initializing experiment
% - bcam was turned off properly
% - miniscope kept running

% how to fix it:
% - cut behavior at the beginning to get to 47993 frames
% - align miniscope with shocks (cant determine how many frames were before
% / after otherwise)
% - cut frames and save

%% PROBLEM ILLUSTRATION 
% miniscope
clear
movPath = 'Y:\E7_miniscope_concat\M10\Session9\rawMovie_original.h5';
info = h5info(movPath);

bDir = 'G:\E7_2DAA\behavior\session9\subject10';
vr = VideoReader(fullfile(bDir,'behavior1.avi'));

load(fullfile(bDir,'input_data.mat'))

load('G:\E7_2DAA\results\behavior\tracks\subject10\session9\centroids_original.mat')

nFramesMs = info.Datasets.Dataspace.Size(3)
nFramesBe = vr.Duration * vr.FrameRate
nFramesTarget = 47993


%% fix tracking (just cut in beginning, as bcam was turned off properly)
centroid = centroid(:,nFramesBe-nFramesTarget+1:end);
savePath = 'G:\E7_2DAA\results\behavior\tracks\subject10\session9\centroids.mat';
save(savePath,'centroid')


%% load subset of movie and calculate frame mean to find shocks
start = 1;
stop = nFramesMs;
chunkSize = [50, 50, stop+1-start];
m = h5read(movPath,'/1',[1 1 start], chunkSize);
for i = 1:size(m,3)
    frame_mean(i) = mean2(m(:,:,i));
end


%% load nidaq data and find shock times for alignment 
load('G:\E7_2DAA\behavior\session9\subject10\input_data.mat')
shock = inputData(3,:) - mean(inputData(3,:)) > 3.8; % convert analog TTL signal to digital
shock = downsample(shock',50)';


%% align
% found matching peaks e.g. at 11910 and 10863 -> plot and fine tune
figure 
hold on
plot([zeros(1,1043) shock]-0.5)
plot(mat2gray(frame_mean(1:50000)))


%% -> cut 1043 at the beginning and the rest at the end
fm = frame_mean;
fm = fm(1044:end);
fm = fm(1:47993);

figure 
hold on
plot(shock)
plot(mat2gray(fm))

%% load movie, fix and save a copy

movie = loadMovie(movPath);
movie = movie(:,:,1044:end);
movie = movie(:,:,1:47993);
movPath_fixed = 'G:\Session9_2daa_m10\rawMovie.h5';

h5create(movPath_fixed, '/1', size(movie), 'Datatype', 'uint16');    
h5write(movPath_fixed, '/1', movie);

    
    