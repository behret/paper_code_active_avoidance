% - use joint results and apply to single session
% - rerun preprocessing without lowpass filter and compare

% - define circle around centroid
% - define cell area using threshold
% - take cell out of circle -> ring
% - correlate ring vs. cell (original / thresholded)

%% 
clear
p = params_2DAA;
saveFig = 1;
data_path = 'G:\SRM_results\one_subspace_task_decoding\neuropil_analysis';

%%
sub = 11;
ses = 1;
r_out = 35;
r_in = 30;
thresh = .6;
    
%% get filters
thisSub = p.subjects(sub);
fpath = fullfile(p.rootDir,'results','filters.mat');
load(fpath,'filters')
filters = filters{sub};
[ areas,centroids,cvxHulls,cvxAreas,outlines ] = getFilterProps( filters );

%% define rings
filters_r = filters;
pad = 50;

disk = zeros(2*pad+1,2*pad+1);
disk(pad+1,pad+1) = 1;
out_disk = imdilate(disk,strel('disk', r_out,0));
in_disk = imdilate(disk,strel('disk', r_in,0));
ring = out_disk;
ring(in_disk == 1) = 0;

for c = 1:size(filters,3)
    cent_im = zeros(size(filters,1)+pad*2,size(filters,2)+pad*2);
    cent_idx = round(centroids(c,:));
    cent_im(cent_idx(2):cent_idx(2)+pad*2,cent_idx(1):cent_idx(1)+pad*2) = ring;
    cent_im = cent_im(pad+1:end-pad,pad+1:end-pad);
    cent_im = cent_im ./ norm(cent_im(:));
    filters_r(:,:,c) = cent_im;
end

%% cut filters
filters_c = filters;
for c = 1:size(filters,3)
    cell_fil = filters(:,:,c);
    cell_bw = cell_fil > thresh*max(cell_fil(:));
    cell_fil(~cell_bw) = 0;
    filters_c(:,:,c) = cell_fil;
end


%% load and warp movies
% for warping
regPath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment',['registrationCoords_Session' num2str(ses) '.mat']);
load(regPath)

% preprocessed
movPath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'preprocessed','preprocessedMovie.h5');
movie = loadMovie(movPath);
ov = imref2d(size(movie(:,:,1)));
movie_warp = imwarp(movie,tform,'OutputView',ov,'FillValues',0);
movie_warp = movie_warp(N:S,W:E,:);

% no lowpass
movPath = 'G:\E7_2DAA\results\preprocessedMovie_no_lowpass.h5';
movie = loadMovie(movPath);
movie_warp_nl = imwarp(movie,tform,'OutputView',ov,'FillValues',0);
movie_warp_nl = movie_warp_nl(N:S,W:E,:);

%% apply the different filters
% flatten and project
[height,width,nFilters] = size(filters);
filters_flat = reshape(filters,height * width, nFilters);
filters_r_flat = reshape(filters_r,height * width, nFilters);
filters_c_flat = reshape(filters_c,height * width, nFilters);

% preprocessed
[height, width, num_frames] = size(movie_warp);
movie_flat = reshape(movie_warp, height * width, num_frames);
traces = (movie_flat' * filters_flat)';    
traces_r = (movie_flat' * filters_r_flat)';
traces_c = (movie_flat' * filters_c_flat)';

% no lowpass
[height, width, num_frames] = size(movie_warp_nl);
movie_flat = reshape(movie_warp_nl, height * width, num_frames);
traces_nl = (movie_flat' * filters_flat)';    
traces_r_nl = (movie_flat' * filters_r_flat)';
traces_c_nl = (movie_flat' * filters_c_flat)';


%% calc corr for traces and ring traces

ccs = [];
for c = 1:size(traces,1)
    cc = corrcoef(traces(c,:),traces_r(c,:));
    cc_nl = corrcoef(traces_nl(c,:),traces_r_nl(c,:));
    ccs(c) = cc(1,2);
    ccs_nl(c) = cc_nl(1,2);
end


%% get data for example cell
this_c = 240;

this_fil = zeros([size(filters,1) size(filters,2) 3]);
ring_col = [200 100 150]/255;
for i = 1:3
    this_fr = mat2gray(filters(:,:,this_c));
    this_fr(filters_r(:,:,this_c) ~= 0) = ring_col(i);
    this_fil(:,:,i) = this_fr;
end
this_cent = round(centroids(this_c,:));

this_trace_r = traces_r(this_c,:);
this_trace = traces(this_c,:);

this_trace_r_nl = traces_r_nl(this_c,:);
this_trace_nl = traces_nl(this_c,:);



%% save data
save(data_path,'ccs','ccs_nl','this_fil','this_cent','this_trace_r','this_trace','this_trace_r_nl','this_trace_nl','this_c')

%% plot
plot_neuropil_analysis