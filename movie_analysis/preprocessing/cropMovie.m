function movie = cropMovie(movie,zeroMask)
% crops movie (i.e. sets borders to zero), such that every row or column that
% is zero because of motion correction for some frame is set to zero for
% all frames

    [N, S, W, E] = getCropCoords( zeroMask );
    
    % getCropCoords gives the values that are included in the 'good' area  
    N = N-1;
    S = S+1;
    W = W-1;
    E = E+1;

    movie(1:N,:,:) = 0;
    movie(S:end,:,:) = 0;
    movie(:,1:W,:) = 0;
    movie(:,E:end,:) = 0;
 
    disp(['pixels cropped (N S W E) : ' num2str([N, size(movie,1) - S + 1, W, size(movie,2) - E + 1])])
    
end