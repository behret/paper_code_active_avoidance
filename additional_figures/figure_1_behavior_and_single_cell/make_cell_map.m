clear
p = params_2DAA;
saveFig = 1;

% load raw frames and std-frames
fpath = 'G:\E7_2DAA\misc\raw_data_snippets\raw_frames';
load(fpath,'raw_frames')
fpath = 'G:\E7_2DAA\results\std_frames';
load(fpath,'frames_aligned')

fpath = fullfile(p.rootDir,'results','filters.mat');
load(fpath,'filters')
%%
for sub = 11%1:12
    thisSub = p.subjects(sub);
    [ areas,centroids,cvxHulls,cvxAreas,outlines ] = getFilterProps( filters{sub} );

    %% process cell data
    thresh = 0.65;
    filters_clean = filters{sub};

    for i = 1:size(filters{sub},3)  
        % get bigges connected component and take convex hull 
        f = mat2gray(filters{sub}(:,:,i));
        pic = f > thresh;
        bwcc = bwconncomp(pic);
        [~,maxIdx] = max(cellfun(@(x) length(x),bwcc.PixelIdxList));
        pic(:) = 0;
        pic(bwcc.PixelIdxList{maxIdx}) = 1;
        pic = bwconvhull(pic);
        filters_clean(:,:,i) = pic;
    end
    
    cellmap = max(filters_clean,[],3);

    
    %% get raw frame and transform to align with cell map
    % transform raw frame
    fpath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment','registrationCoords_Session1.mat');
    load(fpath)
    frame = raw_frames{sub};
    frame_aligned = imwarp(frame,tform,'OutputView',imref2d(size(frame)));
    frame_aligned = frame_aligned(N:S,W:E);
   
    % filter raw frame
    p.filtering.lowpassFreq = 4;
    [ frame_fil,~ ] = filterMovie( p,frame_aligned,'lowpass' );

    
    %% load std frame (already warped)
    std_frame = squeeze(nanmean(frames_aligned{sub},3));
    % take the log as theres outliers with high SNR
    std_frame = log(std_frame);
    
    %% save data
    fpath = fullfile(p.data_dir,'cell_map_data');
    save(fpath,'frame_fil','std_frame','cvxHulls')

end

