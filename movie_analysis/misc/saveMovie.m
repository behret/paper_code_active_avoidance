function [ output_args ] = saveMovie( movie,savePath )
%SAVEMOVIE saves movie to h5 file
 
    h5create(savePath, '/1', size(movie), 'Datatype', 'single');    
    h5write(savePath, '/1', movie);

end

