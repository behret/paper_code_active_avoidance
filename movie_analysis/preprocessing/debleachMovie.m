function [movie_corrected,bleach_filters,bleach_traces,temporal] = debleachMovie( p,movie )

    % smooth movie in time 
    [height,width,n_frames] = size(movie);
    movie = reshape(movie,[height * width,n_frames]);
    smooth_win = 2000;
    M = zeros(size(movie));
    parfor i = 1:size(movie,1)
        M(i,:) = smooth(movie(i,:),smooth_win*2+1)';
    end
    % cut away parts outside of filtering window
    M = M(:,smooth_win+1:end-smooth_win); 
    
    % run PCA
    num_PCs = 10;
    mean_M = mean(M,1); % make each frame zero-mean in place
    M = bsxfun(@minus, M, mean_M);
    C = cov(M, 1); % Normalized by num_pixels
    num_pixels = size(M,1);
    C = num_pixels*C; % Undo the normalization
    options.issym = 'true';
    C = double(C); % Conversion needed for 'eigs'
    [temporal, cov_eigs] = eigs(C, num_PCs, 'LM', options);
    cov_eigs = diag(cov_eigs)'; % Don't need the matrix
    S = diag(cov_eigs.^(1/2)); % Singular values
    % Compute the corresponding spatial PCs
    spatial = (M * temporal) / S;
    bleach_filters = reshape(spatial,[height,width,num_PCs]);

    %% calculate temporal weights, construct rank-n model and subtract    
    mean_movie = mean(movie,1); % make each frame zero-mean in place
    movie = bsxfun(@minus, movie, mean_movie);
    bleach_traces = movie'*spatial;
    model_dims = [1 2];
    model = spatial(:,model_dims)*bleach_traces(:,model_dims)';
    movie_corrected = movie - model;
    movie_corrected = movie_corrected - min(movie_corrected(:)); % make all pixels non-negative
    movie_corrected = reshape(movie_corrected,[height,width,n_frames]);
    

end