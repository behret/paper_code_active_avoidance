function [spatial, temporal, S] = compute_pca_joint( p,thisSub )
% to be able to work with large movies, we calculate the covariance
% matrix batchwise, in order to avoid loading the whole movie into
% memory

    %% get info on movie batches (session movies)
    sub = find(p.subjects == thisSub);
    used_sessions = setdiff(1:p.nSessions,p.alignment.exclude{sub});
    nBatches = length(used_sessions);
    
    for i = 1:nBatches
        ses = used_sessions(i);
        movPaths{i} = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'preprocessed','preprocessedMovie.h5');
        regPaths{i} = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment',['registrationCoords_Session' num2str(ses) '.mat']);
        info = h5info(movPaths{i});
        nFrames = info.Datasets.Dataspace.Size(3);
        movieLengths(i) = nFrames;
    end
    
    if p.PCAICA.approximateExtraction.flag
        nFrames = p.PCAICA.approximateExtraction.window(2)  - p.PCAICA.approximateExtraction.window(1) + 1;
        batchBorders = 0:nFrames:nBatches*nFrames;
    else
        batchBorders = [0 cumsum(movieLengths)];
    end

    % save data thats needed for concatenation 
    savePath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],'jointExtraction','alignment','concatData.mat');
    save(savePath,'movPaths','regPaths','movieLengths','batchBorders')
    
    %% loop through batches and fill final cov matrix
    % we don't devide by the number of observations here (i.e. it's not
    % really the cov matrix), since we would have to undo it later 
    
    C = zeros(batchBorders(end),'double');

    pairCount = 0;
    for i = 1:nBatches
        
        % get first batch
        M1 = prepareBatch(p,movPaths{i},regPaths{i},1);
        % save number if pixels which is needed below
        nPix = size(M1,1);

        
        % now calculate cov of this batch with another batch
        for j = i:nBatches
            pairCount = pairCount+1;
            disp([ char(datetime('now')) ' calculating covariance matrix, batch pair ' ... 
                num2str(pairCount) ' of ' num2str(nBatches^2/2+nBatches/2)])
            % get second batch
            if i == j
                M2 = M1;
            else        
                M2 = prepareBatch(p,movPaths{j},regPaths{j},1);
            end

            % calc batch cov
            batchCov = M1'*M2;

            % write to final cov
            C(batchBorders(i)+1:batchBorders(i+1),batchBorders(j)+1:batchBorders(j+1)) = batchCov;
            C(batchBorders(j)+1:batchBorders(j+1),batchBorders(i)+1:batchBorders(i+1)) = batchCov';

        end
    end


    %% calculate pc weights in the temporal dimension
    
    fprintf('%s: Computing temporal PCs...\n', datestr(now));
	options.issym = 'true';
	C = double(C); % Conversion needed for 'eigs'
    if isfield(p.PCAICA,'individual')
        num_pcs = p.PCAICA.individual.nPCs(sub);
    else
        num_pcs = p.PCAICA.nPCs;
    end
	[temporal, cov_eigs] = eigs(C, num_pcs, 'LM', options);
    clear C
    cov_eigs = diag(cov_eigs)'; % Don't need the matrix

	% Keep only positive eigenvalues. Just a safeguard, should not have
	% non-positive eigenvalues, unless the covariance matrix is pathological
	sieve = cov_eigs > 0;
	temporal = temporal(:, sieve);
	cov_eigs = cov_eigs(:, sieve);
	num_PCs = sum(sieve);
	clear sieve;

	% Singular values
	S = diag(cov_eigs.^(1/2));

	%% project movie into reduced space
    
	fprintf('%s: Computing corresponding PC filters...\n', datestr(now));
    
    % the required computation is: spatial = (M * temporal) / S;
    % since we don't have the full movie we also do this batchwise:
    % load session movie and transform into joint coordinate space,
    % then project into reduced space (add up spatial over batches)
    
    % initialize spatial variable
    spatial = zeros(nPix,size(S,1),'single');
    
    % loop through movie batches
    for i = 1:nBatches
        % load and transform movie batch
        M = prepareBatch(p,movPaths{i},regPaths{i},1);
        % project into reduced space and add to spatial variable
        spatial = spatial + M * temporal(batchBorders(i)+1:batchBorders(i+1),:);
    end
    % divide by signular values (whitening for ICA)
	spatial = spatial / S;
    
    % Output formatting
	temporal  = temporal';  % [num_PCs x time]
	spatial = spatial'; % [num_PCs x space]
    
end

