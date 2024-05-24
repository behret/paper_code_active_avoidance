figure('Position',[100 100 1000 380])
for sub = 1:p.nSubjects
    subplot(2,6,sub)
    imagesc(mses(:,:,sub),[0 0.0003])
    title(['Sub. ' num2str(sub)])
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    
    if sub == 1 || sub == 7
        ylabel('Day')
        set(gca,'YTick',[1 11])
    end
    if sub > 6
        xlabel('Day')
        set(gca,'XTick',[1 11])
    end
end
fpath = fullfile(p.out_dir,'figS3','cellmap_mses.svg');
saveas(gca,fpath,'svg')

