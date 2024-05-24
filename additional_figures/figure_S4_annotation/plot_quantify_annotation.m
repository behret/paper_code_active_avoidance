%% plot diam distributions
this_cols = {'g','r'};
this_alpha = {0.5,0.6};
saveFigs = 1;

ad = cat(2,all_diam{:});
ad = ad*1.25; % convert from pixel to microns
av = cat(1,all_valid{:});

figure('Position',[100 100 300 300])
hold on
histogram(ad(av ~= 1),0:2:60,'Normalization','Probability','FaceColor',this_cols{2},'FaceAlpha',this_alpha{2})
histogram(ad(av == 1),0:2:60,'Normalization','Probability','FaceColor',this_cols{1},'FaceAlpha',this_alpha{1})

ylabel('Probability')
xlabel('Diameter (\mum)')
xlim([0 60])

if saveFigs
    fpath = fullfile(p.out_dir,'figS4','hist_diam.svg');
    saveas(gca,fpath,'svg')
end

%% plot sym value distributions
as = cat(2,all_sym{:});
av = cat(1,all_valid{:});

figure('Position',[100 100 300 300])
hold on
histogram(as(av ~= 1),-.2:0.03:0.6,'Normalization','Probability','FaceColor',this_cols{2},'FaceAlpha',this_alpha{2})
histogram(as(av == 1),-.2:0.03:0.6,'Normalization','Probability','FaceColor',this_cols{1},'FaceAlpha',this_alpha{1})

ylabel('Probability')
xlabel('Sym. Index')
xlim([-.2 .6])

if saveFigs
    fpath = fullfile(p.out_dir,'figS4','hist_sym.svg');
    saveas(gca,fpath,'svg')
end
%% plot n events
all_mn = cat(1,ev_mns{:});
all_std = cat(1,ev_std{:});
av = cat(1,all_valid{:});

figure('Position',[100 100 300 300])
hold on
histogram(all_mn(av ~= 1),0:4:100,'Normalization','Probability','FaceColor',this_cols{2},'FaceAlpha',this_alpha{2})
histogram(all_mn(av == 1),0:4:100,'Normalization','Probability','FaceColor',this_cols{1},'FaceAlpha',this_alpha{1})

ylabel('Probability')
xlabel('Mean Num. Events/Day')
xlim([0 100])

if saveFigs
    fpath = fullfile(p.out_dir,'figS4','hist_num_events.svg');
    saveas(gca,fpath,'svg')
end
%% plot n snap dissim

all_sd = cat(2,snap_d{:});
av = cat(1,all_valid{:});

figure('Position',[100 100 300 300])
hold on
histogram(all_sd(av ~= 1),0:0.01:0.25,'Normalization','Probability','FaceColor',this_cols{2},'FaceAlpha',this_alpha{2})
histogram(all_sd(av == 1),0:0.01:0.25,'Normalization','Probability','FaceColor',this_cols{1},'FaceAlpha',this_alpha{1})

ylabel('Probability')
xlabel('Snapshot Dissimilarity')
xlim([0 0.25])
    
if saveFigs
    fpath = fullfile(p.out_dir,'figS4','hist_snapshots.svg');
    saveas(gca,fpath,'svg')
end


%% plot ev_cv

all_cv = cat(1,ev_cv{:});
av = cat(1,all_valid{:});

figure('Position',[100 100 300 300])
hold on
histogram(all_cv(av ~= 1),0:0.1:4,'Normalization','Probability','FaceColor',this_cols{2},'FaceAlpha',this_alpha{2})
histogram(all_cv(av == 1),0:0.1:4,'Normalization','Probability','FaceColor',this_cols{1},'FaceAlpha',this_alpha{1})

ylabel('Probability')
xlabel('CV_{Num. Events}')
xlim([0 3])
    
if saveFigs
    fpath = fullfile(p.out_dir,'figS4','hist_event_cvs.svg');
    saveas(gca,fpath,'svg')
end
