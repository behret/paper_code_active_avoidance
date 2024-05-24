[cols,alpha] = chooseColors;

rep_mean = squeeze(mean(mean_acc));

figure('Position',[100 100 300 300])
hold on

plot(rep_mean'*100)
xlim([0 31])
set(gca,'XTick',[0 5 10 15 20 25 30])
set(gca,'XTickLabel',[-1 0 1 2 3 4 5])
xlabel('Time (s)')
ylabel('Accuracy (%)')

% indicate tone start and action start 
plot([5 5],[40 100],'k','HandleVisibility','off')

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','tone_decoding_per_sub.svg');
    saveas(gca,fpath,'svg')
end


%% load data from basic analysis of tone decoding (pooled subs) and calculate
% CCs to see how the individuals compare to the pooled version
fpath = fullfile(p.data_dir,'identification_of_tone_dim');
load(fpath,'eval_accs')
dc_means = cellfun(@(x) squeeze(mean(x)),eval_accs,'UniformOutput',false);
rep_mean_pooled = mean(cat(1,dc_means{:}));

ccs = [];
for sub = 1:p.nSubjects
    cc = corrcoef(rep_mean_pooled,rep_mean(sub,:));
    ccs(sub) = cc(1,2);
end

disp(['Pearson correlation coefficient: ' num2str(round(mean(ccs),3)) ' +- ' num2str(round(std(ccs),3))])
