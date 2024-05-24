
clear
p = params_2DAA; 
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')


%% plot activity traces for multiple sessions
cellIdx = 1:10;

for sub = 3%1:p.nSubjects
    len = 400;
    start = 2001;
    stop = start+len-1;
    sep = 100;

    figure('Position',[200 200 700 300],'Renderer','painters')
    hold on

    for i = 1:10
        tr = zeros(1,sep)/0;
        for ses = [1 5 9]
            tr = cat(2,tr,traces{sub,ses}(cellIdx(i),start:stop));
            tr = cat(2,tr,zeros(1,sep)/0);
        end
        plot(tr/5 + i,'k')
    end

    xlim([0 length(tr)])
    ylim([0 11])
    set(gca,'XTick',[len/2+sep len/2+len+2*sep len/2+2*len+3*sep])
    set(gca,'XTickLabel',{'day 1','day 6','day 11'})
    ylabel('example cells')
    
    set(gca,'YTick',[1:10])
    set(gca,'YTickLabel',fliplr(1:10))
    
end

fpath = fullfile(p.out_dir,'fig1','example_cells_spontaneous_activity.svg');
saveas(gca,fpath,'svg')
