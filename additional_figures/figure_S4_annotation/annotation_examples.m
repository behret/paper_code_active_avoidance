    

    %% get necessary data
    clear
    p = params_2DAA;
    sub = 11;
    sub = p.subjects(sub);
    
    % get heuristic sorting if any
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(sub)],'jointExtraction','sorted','heuristic_sorting.mat');
    if exist(fpath)
        sData = load(fpath,'heuristic_sorting');
        sortIdx = sData.heuristic_sorting;
    else
        sortIdx = 1:p.PCAICA.nICs;
    end
    
    % load results from PCA ICA
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(sub)],'jointExtraction','extracted','resultsPCAICA.mat');
    fData = load(fpath,'filters');
    filters = fData.filters(:,:,sortIdx);
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(sub)],'jointExtraction','extracted','norm_traces.mat');
    tData = load(fpath,'traces');
    traces = tData.traces(sortIdx,:); 
    
    % load prepared event data 
    fpath = 'G:\SRM_results\one_subspace_task_decoding\event_snapshots_for_annotation_fig';
    load(fpath,'snapshotCollections','events')
    snapshotCollections = snapshotCollections(sortIdx);
    events = events(sortIdx);

    %% get result of annotation to find early rejected cell
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(sub)],'jointExtraction','sorted','PCAICAsorted.mat');
    load(fpath,'valid')
    
    %% use the full figure to choose examples, then run function to get nice plots
    good_cells = find(valid)';
    bad_cells = find(~valid)';
        
    %% save data for selected cells
    for i = [good_cells(6) bad_cells(55)]
        if i == good_cells(6)
            fpath = fullfile(p.data_dir,'annotation_examples_good');
        else
            fpath = fullfile(p.data_dir,'annotation_examples_bad');
        end
        
        this_traces = traces(i,:);
        this_filters = filters(:,:,i);
        this_events = events(i);
        this_snapshotCollections = snapshotCollections(i);
        
        save(fpath,'this_traces','this_filters','this_events','this_snapshotCollections')
    end
    
    %% plot
    plot_annotation_examples
