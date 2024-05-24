m = loadMovie('G:\E7_2DAA\miniscope\subject13\session1\preprocessed\preprocessedMovie.h5',1,1000);
savePath = 'G:\E7_2DAA\misc\example_movie_data\preprocessed.h5';
saveMovie(m,savePath)

m = loadMovie('\\DROBO6\Public\E7_miniscope_concat\M13\Session1\rawMovie.h5',1,4000);
savePath = 'G:\E7_2DAA\misc\example_movie_data\raw.h5';
saveMovie(m,savePath)
