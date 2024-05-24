function [ trace ] = align_trial_traces( trace )
%ALIGN_TRIAL_TRACES Summary of this function goes here
%   Detailed explanation goes here


    %% figure out starting quadrant
    
    q = get_quadrant(trace(:,1));
    
    %% adjust trace according to starting quadrant

    if q == 2 % flip horizontally
        trace(1,:) = 428 - trace(1,:); 
    elseif q == 3 % flip vertically
        trace(2,:) = 848 - trace(2,:); 
    elseif q == 4 % flip vertically and horizontally
        trace(1,:) = 428 - trace(1,:); 
        trace(2,:) = 848 - trace(2,:); 
    end


end