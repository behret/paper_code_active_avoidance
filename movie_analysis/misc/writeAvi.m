function [ output_args ] = writeAvi( movie,frameRate,fpath )
%WRITEMOVIE Summary of this function goes here
%   Detailed explanation goes here

    v = VideoWriter(fpath,'Grayscale AVI');
    v.FrameRate = frameRate;
    open(v)
    writeVideo(v,movie);
    close(v)
end

