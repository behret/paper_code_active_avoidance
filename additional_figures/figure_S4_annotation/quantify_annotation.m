% plot distributions of some characteristics of accepted and rejected cells

% - diameter
% - symmetry of mean peak
% - n events per session
% - std of events per session
% - mse of snapshots

%% get necessary data
clear
p = params_2DAA;
fpath = fullfile(p.rootDir,'results','allData.mat');
load(fpath,'evs') % needed for getting time steps per session below


%% get valid idx for every subject
% get results of annotation and integrate split detection

all_valid = {};
all_diam = {};
for sub = 1:12
    thisSub = p.subjects(sub);

    %% get result of annotation and figure out cells that were detected as splits
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','PCAICAsorted.mat');
    load(fpath,'valid')
    valid_idx = find(valid);

    % load exlusion index and also mark these cells as invalid
    fpath_excl = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','split_detection.mat');
    load(fpath_excl,'excl_idx')
    split_idx = valid_idx(excl_idx);
    valid(split_idx) = 0;

    all_valid{sub} = valid;
end


%% calc measures per sub

all_diam = {};
all_sym = {};
lag = 5;
ev_mns = {};
ev_std = {};
snap_d = {};

for sub = 1:12
    %% load data
    sub
    thisSub = p.subjects(sub);

    % get heuristic sorting 
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','heuristic_sorting.mat');
    load(fpath,'heuristic_sorting');

    % load filters
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','resultsPCAICA.mat');
    load(fpath,'filters');
    filters = filters(:,:,heuristic_sorting);

    % load traces
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','extracted','norm_traces.mat');
    load(fpath,'traces');
    traces = traces(heuristic_sorting,:); 

    % load events and eventSnapshots
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(thisSub)],'jointExtraction','sorted','eventData');
    load(fpath,'events','eventSnapshots')
    events = events(heuristic_sorting);
    eventSnapshots = eventSnapshots(heuristic_sorting);

    %% estimate diameter with regionprops
    thresh = 0.6;
    diams = [];
    for i = 1:size(filters,3)  
        pic = filters(:,:,i);
        pic = pic > thresh*max(pic(:));

        % get biggest connected component
        bwcc = bwconncomp(pic);
        [~,maxIdx] = max(cellfun(@(x) length(x),bwcc.PixelIdxList));
        pic(:) = 0;
        pic(bwcc.PixelIdxList{maxIdx}) = 1;

        props = regionprops(pic,'MajorAxisLength');
        diams(i) = props.MajorAxisLength;
    end
    all_diam{sub} = diams;

    %% calc sym ratio
    sym_ratio = [];
    for i = 1:length(events)
        % get cutouts around events
        transMat = [];
        for e = 1:length(events{i})
            if events{i}(e)>20 && events{i}(e) < size(traces,2)-30
                thisTrans = traces(i,events{i}(e)-20:events{i}(e)+30);
                transMat = cat(1,transMat,thisTrans);
            end
        end

        if ~isempty(transMat)
            mean_trans = nanmean(transMat,1);
            peak = mean_trans(21); 
            pre_peak = mean_trans(21-lag);
            post_peak = mean_trans(21+lag);
            sym_ratio(i) = (post_peak-pre_peak)/peak;
        end
    end
    all_sym{sub} = sym_ratio;

    %% calc number of events mean and std
    num_ev = [];
    nt = 11998;
    for i = 1:length(events)
        for ses = 1:p.nSessions
            ses_start = (ses-1)*nt;
            ses_end = ses*nt;
            num_ev(i,ses) = sum(events{i} > ses_start & events{i} < ses_end);  
        end
    end

    ev_mns{sub} = mean(num_ev,2);
    ev_std{sub} = std(num_ev,[],2);
    ev_cv{sub} = std(num_ev,[],2)./mean(num_ev,2);

    %% calc snapshot dissimilarity
    errors = {};
    for c = 1:length(eventSnapshots)
        if ~isempty(eventSnapshots{c})
            filIm = mat2gray(eventSnapshots{c}{1});
            for e = 1:length(eventSnapshots{c})-1
                errors{c}(e) = immse(filIm,mat2gray(eventSnapshots{c}{e+1}));
            end
        else
            errors{c} = inf;
        end
    end
    snap_d{sub} = cellfun(@(x) mean(x),errors);
end


%% save data
fpath = fullfile(p.data_dir,'annotation_quantification');
save(fpath,'all_valid','all_diam','all_sym','ev_mns','ev_std','snap_d','ev_cv')

%% plot 
plot_quantify_annotation