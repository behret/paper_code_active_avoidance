function im = warpIm(im,mask)

    targetRowLen = size(im,2);
    % go through rows and do interpolation
    for i = 1:size(im,1)
        startIdx = find(mask(i,:),1,'first');
        rowLen = targetRowLen - (startIdx-1);
        im(i,:) = interp1(1:rowLen,single(im(i,startIdx:end)),linspace(1,rowLen,targetRowLen));
    end

end
