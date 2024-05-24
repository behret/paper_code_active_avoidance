function [ movie,zeroMask,regCoords ] = registerMovie(p,movie,regCoords)
%REGISTERMOVIE registeres movie using turboreg. first registration 
%coordinates are obtained on the a bandpass filtered and inverted version
%of the movie. The original movie is then registered with these coordinates  

% registerMovie is running into memory problems here -> filter in 
% turboreg parfor loop instead of first filtering and then registering

    if isempty(regCoords)
               
        %% Get registration coordinates with turboreg
        disp([char(datetime('now')) ' registering movie: starting turboreg'])

        % set params 
        options = p.turboreg.options;

        % generate cufoff mask for filtering
        padSize = size(movie,1);
        filterSize = [size(movie,1) + 2*padSize , size(movie,2) + 2*padSize];
        lowpassFilter = mat2gray(fspecial('gaussian',filterSize,p.turboreg.bandpassFreqs(2)));
        highpassFilter = 1 - mat2gray(fspecial('gaussian',filterSize,p.turboreg.bandpassFreqs(1)));
        cutoffFilter = highpassFilter.*lowpassFilter;

        % get reference frame and set mask (just a dummy variable that is not
        % really used)
        refPic = single(movie(:,:,p.turboreg.refFrame));
        %bandpass filder, invert, normalize and mean subtract frames
        refPic = filterImage(refPic, cutoffFilter, padSize, 'bandpass');
        refPic = mat2gray(imcomplement(refPic));
        refPic = single(refPic - mean(refPic(:)));

        mask = zeros(size(refPic),'single'); 

        % start parallel pool (if there is none yet)
        if p.useParallelProcessing && isempty(gcp('nocreate'))
            parpool(p.numWorkers,'SpmdEnabled',false,'IdleTimeout', 20)
        end

        % run turboreg
        if p.useParallelProcessing
            parfor i = 1:size(movie,3)
                pic = single(movie(:,:,i));
                %bandpass filder, invert, normalize and mean subtract frames
                pic = filterImage(pic, cutoffFilter, padSize, 'bandpass');
                pic = mat2gray(imcomplement(pic));
                pic = single(pic - mean(pic(:)));
                [~,regCoords{i}] = turboreg(refPic,pic,mask,mask,options);
            end
        else
            for i = 1:size(movie,3)
                pic = single(movie(:,:,i));
                pic = filterImage(pic, cutoffFilter, padSize, 'bandpass');
                pic = mat2gray(imcomplement(pic));
                pic = single(pic - mean(pic(:)));
                [~,regCoords{i}] = turboreg(refPic,pic,mask,mask,options);
            end
        end
    else
        % start parallel pool (if there is none yet)
        if p.useParallelProcessing && isempty(gcp('nocreate'))
            parpool(p.numWorkers,'SpmdEnabled',false,'IdleTimeout', 20)
        end
        
        disp([char(datetime('now')) ' using exisiting registration coordinates'])  
    end
%% Perform registration with transfturboreg
    disp([char(datetime('now')) ' registering movie: starting registration'])  
    mask = ones(size(movie(:,:,1)),'single');
    if p.useParallelProcessing
        parfor i = 1:size(movie,3)
            pic = single(movie(:,:,i));
            movie(:,:,i) = transfturboreg(pic,mask,regCoords{i});
        end    
    else
        for i = 1:size(movie,3)
            pic = single(movie(:,:,i));
            movie(:,:,i) = transfturboreg(pic,mask,regCoords{i});
        end    
    end
%% get mask of zero pixels caused by translation 
% used for cropping at the end of preprocessing

    zeroMask = squeeze(max(movie == 0,[],3));


end

