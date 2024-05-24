function movie = prepareBatch(p,movPath,regPath,extractionFlag)
    % extractionFlag should be 1 when using this function for singal extraction
    % extractionFlag should be 0 when using this function for annotation or
    % applying filter to full movies

    % load movie
    if p.PCAICA.approximateExtraction.flag && extractionFlag 
        movie = loadMovie(movPath,p.PCAICA.approximateExtraction.window(1),p.PCAICA.approximateExtraction.window(2));
    else
        movie = loadMovie(movPath);
    end
    
    % register movie
    load(regPath)
    ov = imref2d(size(movie(:,:,1)));
    movie = imwarp(movie,tform,'OutputView',ov,'FillValues',0);

    % crop movie
    movie = movie(N:S,W:E,:);

    if extractionFlag
        % flatten pixel dimensions
        [height, width, num_frames] = size(movie);
        movie = reshape(movie, height * width, num_frames);
        
        % make frames zero mean 
        frameMeans = mean(movie,1);
        movie = bsxfun(@minus,movie,frameMeans);
    end
end