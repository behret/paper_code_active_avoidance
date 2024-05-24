    % rerun preprocessing without lowpass filter for an example session
    % sub = 11 (thisSub = 13)
    % ses = 1
    % we can reuse the regCoords
    clear
    p = params_2DAA;
    moviePath = '\\DROBO6\Public\E7_miniscope_concat\M13\Session1\rawMovie.h5';
    saveDir = 'G:\E7_2DAA\results';
    regPath = 'G:\E7_2DAA\miniscope\subject13\session1\preprocessed\regCoords.mat';
    load(regPath)

    %% (saved movie after this since it took quite long and I might need it again)
    disp([char(datetime('now')) ' loading movie'])
    movie = single(loadMovie(moviePath));
    
    disp([char(datetime('now')) ' registering movie'])
    [movie,zeroMask,regCoords] = registerMovie(p,movie,regCoords);
        
    disp([char(datetime('now')) ' downsampling movie in time'])
    movie = downsampleMovie(p,movie,'time');
    
    % need to do cropping before debleach!
    disp([char(datetime('now')) ' cropping movie'])
    movie = cropMovie(movie,zeroMask);

    %%
    %savePath = fullfile(saveDir,'preprocessedMovie_mc_down.h5');
    %movie = single(loadMovie(savePath));
    
    disp([char(datetime('now')) ' debleaching movie'])
    [movie,bleach_filters,bleach_traces,bleach_traces_smooth] = debleachMovie(p,movie); 
    
    %disp([char(datetime('now')) ' filtering movie: dividing by lowpass'])
    %[movie,lfi] = filterMovie(p,movie,'lowpass');

    disp([char(datetime('now')) ' dfof-ing movie'])
    movie = dfofMovie(movie);
    
    % crop again to undo any effects of filtering / dfof
    disp([char(datetime('now')) ' cropping movie'])
    movie = cropMovie(movie,zeroMask);

    savePath = fullfile(saveDir,'preprocessedMovie_no_lowpass.h5');
    saveMovie(movie,savePath)
    
    