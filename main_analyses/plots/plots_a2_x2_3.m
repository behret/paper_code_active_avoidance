%%
[cols,alpha] = chooseColors;

dc_mean = squeeze(mean(eval_accs,1));
rep_mean = squeeze(mean(dc_mean,4));
ae_mean = squeeze(mean(rep_mean,3));

figure('Position',[100 100 300 300])
hold on

plot(ae_mean'*100)
xlim([0 21])
set(gca,'XTick',[0 5 10 15 20])
set(gca,'XTickLabel',[-3 -2 -1 0 1])
xlabel('Time (s)')
ylabel('Accuracy (%)')

%indicate tone start and action start 
plot([15 15],[40 100],'k','HandleVisibility','off')


if saveFigs
    fpath = fullfile(p.out_dir,'figS8','ae_decoder_per_sub.svg');
    saveas(gca,fpath,'svg')
end


%% load data from basic analysis of avoid dims (pooled subs) and calculate
% CCs to see how the individuals compare to the pooled version
fpath = fullfile(p.data_dir,'identification_of_avoid_dims');
load(fpath,'all_eval_accs')
dc_means = squeeze(mean(all_eval_accs))';
rep_mean_pooled = mean(dc_means);

ccs = [];
for sub = 1:p.nSubjects
    cc = corrcoef(rep_mean_pooled,ae_mean(sub,:));
    ccs(sub) = cc(1,2);
end

disp(['Pearson correlation coefficient: ' num2str(round(mean(ccs),3)) ' +- ' num2str(round(std(ccs),3))])
