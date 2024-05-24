%% plot histograms

this_cols = {[.7 .7 .7],'b'};
ring_col = [200 100 150]/255;


figure('Position',[100 100 300 300])
hold on
histogram(ccs,'FaceColor',this_cols{1})
histogram(ccs_nl,'FaceColor',this_cols{2})
xlabel('Corr. Coef.')
ylabel('# Cells')
legend({'w/ lowpass norm.','w/o lowpass norm.'})
ylim([0 120])

fpath = fullfile(p.out_dir,'figS3','neuron_vs_ring_corr.svg');
saveas(gca,fpath,'svg')

disp(median(ccs))
disp(median(ccs_nl))

%% plot example cell filter + ring
figure('Position',[100 100 300 300])
imagesc(this_fil)
set(gca,'XTick',[])
set(gca,'YTick',[])

xlim([this_cent(1)-59 this_cent(1)+60])
ylim([this_cent(2)-59 this_cent(2)+60])

fpath = fullfile(p.out_dir,'figS3','neuron_vs_ring_filter.svg');
saveas(gca,fpath,'svg')

%% plot for chosen cell
lims = [4001 5000];

figure('Position',[100 100 800 300])
subplot(2,1,1)
hold on
plot(this_trace_r,'Color',ring_col) 
plot(this_trace,'k') 
title(['w/ lowpass norm. (cc = ' num2str(ccs(this_c)) ')'])
xlim(lims)
set(gca,'XTick',[])
ylabel('\Delta F/F (%)')

subplot(2,1,2)
hold on
plot(this_trace_r_nl,'Color',ring_col) 
plot(this_trace_nl,'k') 
title(['w/o lowpass norm. (cc = ' num2str(ccs_nl(this_c)) ')'])
xlim(lims)
ylabel('')
set(gca,'XTick',lims(1)-1:250:lims(2))
set(gca,'XTickLabel',0:50:200)
xlabel('Time (s)')
ylabel('\Delta F/F (%)')

fpath = fullfile(p.out_dir,'figS3','neuron_vs_ring_example.svg');
saveas(gca,fpath,'svg')

