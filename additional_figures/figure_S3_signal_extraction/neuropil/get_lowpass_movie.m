function fil_movie = get_lowpass_movie(p,movie)

    % remove nans
    movie(isnan(movie)) = 0;
    fil_movie = movie;
    %% create cutoffFilter and normalize to be between 0 and 1
    padSize = size(movie,1);
    filterSize = [size(movie,1) + 2*padSize , size(movie,2) + 2*padSize];
    cutoffFilter = mat2gray(fspecial('gaussian',filterSize,p.filtering.lowpassFreq));

    %% filter all frames
    % overwrite in loop to reduce memory
    for i = 1:size(movie,3)
        image = movie(:,:,i);
        inputImage = padarray(image,[padSize padSize],'symmetric');
        % do fft
        inputImageFFT = fft2(inputImage);
        inputImageFFT = fftshift(inputImageFFT);
        % alter freq domain based on filter
        inputImageFFTFiltered = cutoffFilter.*inputImageFFT;
        % transform freq domain back to spatial
        inputImageFiltered = ifftshift(inputImageFFTFiltered);
        inputImageFiltered = ifft2(inputImageFiltered);
        inputImageFiltered = single(real(inputImageFiltered));
        % crop image back to original dimensions
        inputFiltered = inputImageFiltered(padSize+1:end-padSize,padSize+1:end-padSize);
        fil_movie(:,:,i) = inputFiltered;
    end
    
end