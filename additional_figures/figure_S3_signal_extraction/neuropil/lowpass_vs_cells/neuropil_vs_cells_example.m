
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'filters.mat');
load(fpath,'filters')
sub = 1;

%%
randIdx = randperm(size(filters{sub},3));
fr1 = max(filters{sub}(:,:,randIdx(1:10)),[],3);
fr2 = max(filters{sub}(:,:,randIdx(11:20)),[],3);
fr_fil1 = apply_lowpass(p,fr1);
fr_fil2 = apply_lowpass(p,fr2);


%%
p = params_2DAA;
randIdx = randperm(size(filters{sub},3));
fr_cells = max(filters{sub}(:,:,randIdx(1:10)),[],3);
fr = max(filters{sub}(:,:,randIdx(11:20)),[],3);
fr_neuropil = apply_lowpass(p,fr);

lpfs = [0 100 20 14 10 7];

fr_cells = mat2gray(fr_cells);
fr_neuropil = mat2gray(fr_neuropil);


figure
for i = 1:5
    if i == 1
        subplot(2,5,i)
        imagesc(fr_cells,[0 max(fr_cells(:))])

        subplot(2,5,5+i)
        imagesc(fr_neuropil,[0 max(fr_cells(:))])
    else
        p.filtering.lowpassFreq = lpfs(i);
        subplot(2,5,i)
        imagesc(apply_lowpass(p,fr_cells),[0 max(fr_cells(:))])
        subplot(2,5,5+i)
        imagesc(apply_lowpass(p,fr_neuropil),[0 max(fr_cells(:))])
    end
end



%%
mean_pix_val = [];
vals = 5:5:100;
for i = 1:20
    p.filtering.lowpassFreq = vals(i);
    fr = apply_lowpass(p,fr_cells);
    mean_pix_val(i,1) = max(fr(:));
    fr = apply_lowpass(p,fr_neuropil);
    mean_pix_val(i,2) = max(fr(:));
end

figure
plot(mean_pix_val)



