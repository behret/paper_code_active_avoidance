function [ output_args ] = preprocessMovie(p,moviePath,saveDir)
%preprocessMovie: performs all preprocessing steps on raw movies

    disp([char(datetime('now')) ' loading movie'])
    movie = single(loadMovie(moviePath));
    
    disp([char(datetime('now')) ' registering movie'])
    % use existing registration coordinates if available
    regPath = fullfile(saveDir,'regCoords.mat');
    regCoords = {};
    if exist(regPath)
        load(regPath)
    end
    [movie,zeroMask,regCoords] = registerMovie(p,movie,regCoords);
        
    disp([char(datetime('now')) ' downsampling movie in time'])
    movie = downsampleMovie(p,movie,'time');
    
    % need to do cropping before debleach!
    disp([char(datetime('now')) ' cropping movie'])
    movie = cropMovie(movie,zeroMask);
    
    disp([char(datetime('now')) ' debleaching movie'])
    [movie,bleach_filters,bleach_traces,bleach_traces_smooth] = debleachMovie(p,movie); 
    
    disp([char(datetime('now')) ' filtering movie: dividing by lowpass'])
    [movie,lfi] = filterMovie(p,movie,'lowpass');

    disp([char(datetime('now')) ' dfof-ing movie'])
    movie = dfofMovie(movie);
    
    % crop again to undo any effects of filtering / dfof
    disp([char(datetime('now')) ' cropping movie'])
    movie = cropMovie(movie,zeroMask);

    savePath = fullfile(saveDir,'preprocessedMovie.h5');
    saveMovie(movie,savePath)
    save(fullfile(saveDir,'p.mat'),'p')
    save(fullfile(saveDir,'preprocessing_data'),'bleach_filters','bleach_traces','bleach_traces_smooth','lfi')
    if ~exist(regPath)
        save(regPath,'regCoords','-v7.3')
    end
end

