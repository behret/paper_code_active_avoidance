function [ inputFiltered ] = apply_lowpass( p,fr )
%APPLY_LOWPASS Summary of this function goes here
%   Detailed explanation goes here

    padSize = size(fr,1);
    filterSize = [size(fr,1) + 2*padSize , size(fr,2) + 2*padSize];
    cutoffFilter = mat2gray(fspecial('gaussian',filterSize,p.filtering.lowpassFreq));

    image = fr;
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
end

