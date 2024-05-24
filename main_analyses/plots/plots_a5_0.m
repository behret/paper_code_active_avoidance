%%
[cols,alpha] = chooseColors;

lims = [-8 12];
tone_trace = tone_trace * lims(2);
tone_trace(tone_trace == 0) = lims(1);

figure('Position',[100 100 1200 300])
hold on 
plot(proj_trace,'k')
area(tone_trace,'FaceColor',[.7 .7 .7],'FaceAlpha',alpha,'LineStyle','none','BaseValue',lims(1))
ylim(lims)
set(gca,'XTick',[0:300:3000])
set(gca,'XTickLabel',[0:10])
xlabel('Time (min)')
ylabel('Tone Dim. Proj. (a.u)')
if saveFigs
    fpath = fullfile(p.out_dir,'fig7','tone_dim_example.svg');
    saveas(gca,fpath,'svg')
end


%% print cc numbers

sub_mean = squeeze(nanmean(ccs(:,:,:),2));
aa_mean = nanmean(sub_mean(:,2:9),2);
rep_mean = nanmean(aa_mean);
sorted = sort(aa_mean);
rep_ci = sorted([3 78]);

disp(['cc tone vs. tone-proj: ' num2str(rep_mean) ' CI:[' num2str(rep_ci(1)) ' ' num2str(rep_ci(2)) ']'])

