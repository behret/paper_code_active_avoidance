function [ q ] = get_quadrant( cent )
%GET_QUADRANTS Summary of this function goes here
%   Detailed explanation goes here
%     1: NW
%     2: SW
%     3: NE
%     4: SE

    %% get quadrant
    if cent(2) < 424 && cent(1) < 208
        q = 1;
    elseif cent(2) < 424 && cent(1) >= 208
        q = 2;
    elseif cent(2) >= 424 && cent(1) < 208
        q = 3;
    elseif cent(2) >= 424 && cent(1) >= 208
        q = 4;
    end

end

