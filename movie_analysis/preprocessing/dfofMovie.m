function [thisMovie] = dfofMovie(thisMovie)
% converts movie to units of DFOF
    
    % get the movie F0, do by row to reduce potential memory errors	    
    inputMovieF0 = zeros([size(thisMovie,1) size(thisMovie,2)]);
    for rowNo=1:size(thisMovie,1)
        inputMovieF0(rowNo,:) = nanmean(squeeze(thisMovie(rowNo,:,:)),2);
    end
    
    % bsxfun for fast matrix divide
    thisMovie = bsxfun(@ldivide,inputMovieF0,thisMovie);
    thisMovie = thisMovie-1;

end


