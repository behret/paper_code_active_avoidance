function [ inputMovie ] = downsampleMovie(p,inputMovie,dimension)
%downsampleTime downsamples a movie in time, uses floor to calculate downsampled dimensions.
   
    switch dimension
        
        case 'time'
            % downsample the movie in time by downsampling the X*Z 'image' in the Z-plane 
            % and then stacking these downsampled images in the Y-plane. 
            % would work the same for downsampling Y*Z and stacking in the X-plane.
            downX = size(inputMovie,1);
            downY = size(inputMovie,2);
            downZ = floor(size(inputMovie,3)/p.downsampleTime.factor);
           % to reduce memory footprint, place new frame in old movie and cut off the unneeded frames after
            for frame=1:downY
               downsampledFrame = imresize(squeeze(inputMovie(:,frame,:)),[downX downZ],p.downsampleTime.secondaryDownsampleType);
               inputMovie(1:downX,frame,1:downZ) = downsampledFrame;
            end
            inputMovie = inputMovie(:,:,1:downZ);
            drawnow;
    
        case 'space'
            downX = floor(size(inputMovie,1)/p.downsampleSpace.factor);
            downY = floor(size(inputMovie,2)/p.downsampleSpace.factor);
            downZ = size(inputMovie,3);
            % to reduce memory footprint, place new frame in old movie and cut off the unneeded frames after
            for frame=1:downZ
               downsampledFrame = imresize(squeeze(inputMovie(:,:,frame)),[downX downY],p.downsampleSpace.secondaryDownsampleType);
               inputMovie(1:downX,1:downY,frame) = downsampledFrame;
            end
            inputMovie = inputMovie(1:downX,1:downY,:);
            drawnow;
            
        otherwise
            display('incorrect dimension option, choose time or space');
    end

end

