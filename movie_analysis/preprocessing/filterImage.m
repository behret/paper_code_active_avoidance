function [ outputImage,lfi ] = filterImage( image, cutoffFilter, padSize, fType )
%FILTERIMAGE performs frequency domain filtering 

    % pad the array to remove edge effects
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
    lfi = 0; % measure of local field illumination 
    switch fType
        case 'lowpass'
            outputImage = image./inputFiltered;
            lfi = mean(inputFiltered(:));
        case 'bandpass'
            outputImage = inputFiltered;
    end
end

