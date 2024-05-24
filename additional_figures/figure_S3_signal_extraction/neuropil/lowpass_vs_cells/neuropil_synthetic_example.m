%% generate synthetic neural signal and synthetic BG signal
pad_size = 200;
fr_size = 500;
fr_size_pad = fr_size + 2*pad_size;

sd_cells = 5;
sd_bg = 50;

% BG
frame = zeros(fr_size,fr_size);
randIdx = randi(fr_size*fr_size,30,1);
frame(randIdx) = 1;
frame_pad = zeros(fr_size_pad,fr_size_pad);
frame_pad(pad_size+1:end-pad_size,pad_size+1:end-pad_size) = frame;
B = imgaussfilt(frame_pad,sd_bg);
frame_bg = B(pad_size+1:end-pad_size,pad_size+1:end-pad_size);
frame_bg = mat2gray(frame_bg)/2;

% cells
frame = zeros(fr_size,fr_size);
randIdx = randi(fr_size*fr_size,15,1);
frame(randIdx) = 1;
frame_pad = zeros(fr_size_pad,fr_size_pad);
frame_pad(pad_size+1:end-pad_size,pad_size+1:end-pad_size) = frame;
B = imgaussfilt(frame_pad,sd_cells);
frame_cells = B(pad_size+1:end-pad_size,pad_size+1:end-pad_size);
frame_cells = mat2gray(frame_cells);

% do filtering
p.filtering.lowpassFreq = 7;
joint = frame_cells + frame_bg;
joint_fil = apply_lowpass(p,joint);
bg_fil = apply_lowpass(p,frame_bg);
cells_fil = apply_lowpass(p,frame_cells);



%% PLOT WITHOUT REMOVAL RESULT

figure('Position',[100 100 1600 800])
% BG
subplot(2,4,1)
imagesc(frame_cells,[0 1])
set(gca,'XTick',[])
set(gca,'YTick',[])
title('Cells')
subplot(2,4,5)
imagesc(cells_fil,[0 1])
set(gca,'XTick',[])
set(gca,'YTick',[])
title('fil(Cells)')

% cells
subplot(2,4,2)
imagesc(frame_bg,[0 1])
set(gca,'XTick',[])
set(gca,'YTick',[])
title('BG')
subplot(2,4,6)
imagesc(bg_fil,[0 1])
set(gca,'XTick',[])
set(gca,'YTick',[])
title('fil(BG)')

% BG + cells
subplot(2,4,3)
imagesc(joint,[0 1])
set(gca,'XTick',[])
set(gca,'YTick',[])
title('Cells+BG')
subplot(2,4,7)
imagesc(joint_fil,[0 1])
set(gca,'XTick',[])
set(gca,'YTick',[])
title('fil(Cells+BG)')

% diff plot
subplot(2,4,4)
imagesc(abs(joint_fil - bg_fil),[0 1])
set(gca,'XTick',[])
set(gca,'YTick',[])
title('|fil(Cells+BG)-fil(BG)|')

colormap gray

%% PLOT WITH REMOVAL RESULT
p.filtering.lowpassFreq = 7;
joint1 = frame_cells1 + frame_bg;
joint2 = frame_cells2 + frame_bg;

figure
% BG
subplot(3,4,1)
imagesc(frame_bg,[0 1])
subplot(3,4,5)
imagesc(apply_lowpass(p,frame_bg),[0 1])
subplot(3,4,9)
imagesc(frame_bg./apply_lowpass(p,frame_bg),[0 10])

% cells1
subplot(3,4,2)
imagesc(frame_cells1,[0 1])
subplot(3,4,6)
imagesc(apply_lowpass(p,frame_cells1),[0 1])
subplot(3,4,10)
imagesc(frame_cells1./apply_lowpass(p,frame_cells1),[0 10])

% BG + cells1
subplot(3,4,3)
imagesc(joint1,[0 1])
subplot(3,4,7)
imagesc(apply_lowpass(p,joint1),[0 1])
subplot(3,4,11)
imagesc(joint1./apply_lowpass(p,joint1),[0 10])

% BG + cells2
subplot(3,4,4)
imagesc(joint2,[0 1])
subplot(3,4,8)
imagesc(apply_lowpass(p,joint2),[0 1])
subplot(3,4,12)
imagesc(joint2./apply_lowpass(p,joint2),[0 10])
colormap gray



