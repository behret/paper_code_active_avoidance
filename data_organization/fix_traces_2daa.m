function [ traces ] = fix_traces_2daa( traces )

    % fix for M11S7 (dropped frames 2 times -> add nans)
    % recording xml file indicates dropped frames: 
    % 46357 - 46369
    % 46480 - 46491
    % insert one big nan block (also take out frames between the 2 drops)
    % recording is good until first drop: 1:11598
    % then we add nans for the part we take out (33) and 6 for the dropped
    % frames
    % last part is good again 11623:end
    nan_block = zeros(size(traces{9,7},1),39) / 0; 
    tr_fix = [traces{9,7}(:,1:11589) nan_block traces{9,7}(:,11623:end)];

    traces{9,7} = tr_fix;
    
end

