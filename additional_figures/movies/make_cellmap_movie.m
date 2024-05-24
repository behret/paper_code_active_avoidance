% load aligned cell maps and quantify MSE 
clear
p = params_2DAA;

%% load maps

for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        thisSub = p.subjects(sub);
        fpath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'extracted','cellMap.mat');
        load(fpath)
        maps{sub,ses} = cellMap;
    end
end

%% load verified alignments

[ mapsAligned, tforms ] = alignCellMaps(p, maps );


%% good subject and bad subject

mov = mat2gray(cat(3,mapsAligned{11,:}));
mov = repmat(mov,[1 1 1 3]);
mov = permute(mov,[1 2 4 3]);

mov8 = mat2gray(cat(3,mapsAligned{8,:}));
mov8 = repmat(mov8,[1 1 1 3]);
mov8 = permute(mov8,[1 2 4 3]);

% add day  
for d = 1:11
    
    this_frame = mov(:,:,:,d);
    this_frame = insertText(this_frame,[10 10],'Subject 11','TextColor','black','FontSize',20,'BoxColor','white','BoxOpacity',0.8);
    this_frame = insertText(this_frame,[10 50],['Day ' num2str(d)],'TextColor','black','FontSize',20,'BoxColor','white','BoxOpacity',0.8);
    mov(:,:,:,d) = this_frame;
    
    
    this_frame = mov8(:,:,:,d);
    this_frame = insertText(this_frame,[10 10],'Subject 8','TextColor','black','FontSize',20,'BoxColor','white','BoxOpacity',0.8);

    if d > 7
        this_frame = insertText(this_frame,[10 50],['Day ' num2str(d)],'TextColor','red','FontSize',20,'BoxColor','white','BoxOpacity',0.8);
    else
        this_frame = insertText(this_frame,[10 50],['Day ' num2str(d)],'TextColor','black','FontSize',20,'BoxColor','white','BoxOpacity',0.8);
    end
    mov8(:,:,:,d) = this_frame;
end
sep = ones(500,10,3,11)*.7;
mov = cat(2,mov,sep,mov8);

fpath = 'G:\E7_2DAA\results\cellmaps_good_bad.avi';
v = VideoWriter(fpath);
v.FrameRate = 1;
open(v)
writeVideo(v,mov);
close(v)


%% single subject

sub = 11;
mov = mat2gray(cat(3,mapsAligned{sub,:}));

% add day  
text_frame = zeros(size(mov));
for d = 1:11
    this_frame = text_frame(:,:,d);
    this_frame = insertText(this_frame,[10 10],['Day ' num2str(d)],'TextColor','white','FontSize',20);
    this_frame = this_frame(:,:,3);

    mov_frame = mov(:,:,d);
    mov_frame(this_frame ~= 0) = this_frame(this_frame ~= 0);
    mov(:,:,d) = mov_frame;
end

fpath = 'G:\E7_2DAA\results\cellmaps.avi';
writeAvi(mov,1,fpath);
