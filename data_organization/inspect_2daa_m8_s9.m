% NOTE: after fixing this once, the logic of the script doesn't work
% anymore...

% inspecting 2DAA M8S9 (subject10)
% there were several problems with the recording:
% - miniscope started too early
% - miniscope stopped too late
% - bcam started too early (since miniscope was already running, but not as early as miniscope)
% - bcam stopped too late (probably only slightly)

% both traces and tracking data need to be fixed. optimally this should be
% done on the raw data. however this is quite some effort and maybe not even possible
% as an intermediate solution we can fix the processed data: (traces and
% centroids) based on visual alignment.

% traces are fixed in collect_all_data / fix_traces
% centroids are fixed in collect_all_data / fix_bvs

%% load 2DAA data
clear
p = params_2DAA;
fpath = fullfile(p.rootDir,'results','allData.mat');
load(fpath,'tis','traces','bvs','evs')


fpath = fullfile(p.rootDir,'results','ttd_results');
load(fpath,'cellWeights')

%% 
sub = 8;
ses = 9;
diff = 262;

% use tone responses to align
[~,sortIdx] = sort(cellWeights{sub}(2,:));
figure
tmat = traces{sub,ses}(sortIdx,diff+1:end);
tmat = cat(2,tmat,zeros(300,diff)/0);
bmat = repmat(evs{sub,ses}(5,:),[30,1]);
pd = cat(1,tmat,bmat);

imagesc(pd)


%% there is also a mismatch with the tracking data

figure
hold on
sub = 8;
ses = 9;
plot(evs{sub,ses}(6,:))
plot(mat2gray(bvs{sub,ses}(3,:)))




