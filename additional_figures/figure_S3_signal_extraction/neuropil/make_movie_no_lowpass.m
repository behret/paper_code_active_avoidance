%% load movies
thisSub = 13;
ses = 1;

% preprocessed
movPath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'preprocessed','preprocessedMovie.h5');
movie = loadMovie(movPath,1,150);

% no lowpass
movPath = 'G:\E7_2DAA\results\preprocessedMovie_no_lowpass.h5';
movie_nl = loadMovie(movPath,1,150);

movie_fil = get_lowpass_movie(p,movie_nl);

%%

m1 = mat2gray(movie);
%m1(m1>.8) = .8;

m = cat(2,mat2gray(m1),mat2gray(movie_nl),mat2gray(movie_fil)/3);
%m(m>.7) = .7;
%m(m<.2) = .2;
compareMovies(1,150,5,m)


%% 
writeAvi(m,5,'G:\E7_2DAA\results\no_lowpass.avi')

