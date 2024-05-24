[cols,alpha] = chooseColors;


%% FINAL PLOT FOR FIGURE

figure('Position',[100 100 300 300])
imagesc(mean(weight_corrs_null,3),[-.3 1])
set(gca,'XTick',[5 10 15 20]) 
set(gca,'XTickLabel',[-2 -1 0 1])    
set(gca,'YTick',[5 10 15 20]) 
set(gca,'YTickLabel',[-2 -1 0 1])
xlabel('Time (s)')
ylabel('Time (s)')

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','weight_analysis_avoid.svg');
    saveas(gca,fpath,'svg')
end