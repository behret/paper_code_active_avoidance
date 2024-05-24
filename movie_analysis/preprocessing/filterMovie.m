function [ movie,lfi ] = filterMovie( p,movie,fType )
%FILTERMOVIE filters movie according to the paramneters set in p

    % remove nans
    movie(isnan(movie)) = 0;

    %% create cutoffFilter and normalize to be between 0 and 1
    padSize = size(movie,1);
    filterSize = [size(movie,1) + 2*padSize , size(movie,2) + 2*padSize];
    
    switch fType 
        case 'lowpass'
            cutoffFilter = mat2gray(fspecial('gaussian',filterSize,p.filtering.lowpassFreq));
        case 'highpass'
            cutoffFilter = 1 - mat2gray(fspecial('gaussian',filterSize,p.highpassFreq));
        case 'bandpass'
            lowpassFilter = mat2gray(fspecial('gaussian',filterSize,p.turboreg.bandpassFreqs(2)));
            highpassFilter = 1 - mat2gray(fspecial('gaussian',filterSize,p.turboreg.bandpassFreqs(1)));
            cutoffFilter = highpassFilter.*lowpassFilter;
    end

    %% filter all frames
    % overwrite in loop to reduce memory
    lfi = zeros(1,size(movie,3));
    for i = 1:size(movie,3)
        [movie(:,:,i),lfi(i)] = filterImage(movie(:,:,i), cutoffFilter, padSize, fType);
    end
    
    movie = movie - min(movie(:)); % make sure all pixels are non-negative
    
end

