function [ output_args ] = extractJoint( p,thisSub )


%% do path handling, etc 
    saveDir = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','extracted');
    savePath = fullfile(saveDir,'resultsPCAICA.mat');
    if exist(savePath)
        disp('Skipping subject (already done)')
        return
    else
        mkdir(saveDir);
    end
    
    sub = find(p.subjects == thisSub);
    if isfield(p.PCAICA,'individual')
        num_ICs = p.PCAICA.individual.nICs(sub);
    else
        num_ICs = p.PCAICA.nICs;
    end
    
%% PCA
    [spatial, temporal, S] = compute_pca_joint(p, thisSub);
    S = diag(S); % keep only the diagonal of S
    disp([ char(datetime('now')) ' done with PCA, starting ICA'])

%% ICA
    % set parameters
    mu = p.PCAICA.mu;
    term_tol = p.PCAICA.term_tol; 
    max_iter = p.PCAICA.max_iter;  

    % get height and width of movie from alignment to undo flattening of
    % pixel dimension
    fpath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment','alignedCellMaps');
    load(fpath,'mapsCropped');
    height = size(mapsCropped,1);
    width = size(mapsCropped,2);
    
    % run ICA
    ica_mixed = compute_spatiotemporal_ica_input(spatial, temporal, mu);
    ica_W = compute_ica_weights(ica_mixed, num_ICs, term_tol, max_iter)'; 
    [filters, traces] = compute_ica_pairs(spatial, temporal, S, height, width, ica_W);
    traces = permute(traces,[2 1]);


    %% save results
    save(savePath,'p','traces','filters')
    cellMap = squeeze(max(filters,[],3));
    save(fullfile(saveDir,'cellMap'),'cellMap');

end
