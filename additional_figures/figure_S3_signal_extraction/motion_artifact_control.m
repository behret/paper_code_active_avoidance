
clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%% get ITI data
speed_control = 0;
[av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,err_trials_full_all,trans_data_all_dr] = prepare_data_task_subspaces(p, traces, evs, bvs, tis,speed_control);

%% calc mean ITI response and define motion score as mean after action onset

motion_response = {};
motion_score = {};
for sub = 1:p.nSubjects
    this_motion_response = squeeze(mean(cat(3,trans_data_all{sub,:}),3));

    % use -2 to -1 before action start as baseline
    this_bl_response = squeeze(mean(cat(3,trans_data_all{sub,:}),3));
    this_bl_response = this_bl_response(:,1:10);
    
    bl_mean = mean(this_bl_response,2);
    bl_std = std(this_bl_response,[],2);
    this_z = (this_motion_response - bl_mean) ./ bl_std;
    
    motion_response{sub} = this_z;
    motion_score{sub} = mean(this_z(:,21:30),2);
end

profiles = cat(1,motion_response{:});
scores = cat(1,motion_score{:});


%% divide into 3 classes
cutoff = 6;

for sub = 1:p.nSubjects
    m_class{sub} = zeros(size(motion_score{sub}));
    m_class{sub}(motion_score{sub}<-cutoff) = 1;
    m_class{sub}(motion_score{sub}>-cutoff & m_class{sub}<cutoff) = 2;
    m_class{sub}(motion_score{sub}>cutoff) = 3;
end

%% plot example cell: mean ITI response and examples
sub = 1;
[~,sortIdx] = sort(motion_score{sub});
ce = sortIdx(end);

all_iti = cat(3,trans_data_all{sub,:});
this_mean = squeeze(mean(all_iti(ce,:,:),3));

figure('Position',[100 100 300 300])
hold on
% plot example transitions
randIdx = randperm(size(all_iti,3));
for i = 1:10
    this_trace = all_iti(ce,:,randIdx(i));
    plot(this_trace,'Color',[.7 .7 .7])
end
% plot mean
plot(this_mean,'LineWidth',2,'Color','k')

xlabel('Time (s)')
set(gca,'XTick',[0 20 40])
set(gca,'XTickLabel',[-4 0 4])
plot([20 20],[-2 6],'Color',[.7 .7 .7])
ylim([-2 6])
ylabel('\Delta F/F (%)')

fpath = fullfile(p.out_dir,'figS3','motion_response_example_cell.svg');
saveas(gca,fpath,'svg')

%% pool data over subjects

all_scores = cat(1,motion_score{:});
all_profiles = cat(1,motion_response{:});
all_classes = cat(1,m_class{:});


%% plot histogram of motion score
this_cols = {'r','k','g'};
lim = 40;
figure('Position',[100 100 300 300])
hold on
for i = 1:3
    histogram(all_scores(all_classes == i),-lim:2:lim,'FaceColor',this_cols{i})
end

xlabel('Mean Z-Score')
ylabel('# Cells')
xlim([-lim lim])
fpath = fullfile(p.out_dir,'figS3','motion_score_hist.svg');
saveas(gca,fpath,'svg')

%% plot mean of motion response per group
figure('Position',[100 100 300 300])
hold on
sep = 30;
for i = 1:3
    
    this_profiles = all_profiles(all_classes == i,:);
    
    randIdx = randperm(size(this_profiles,1));
    for j = 1:7
        this_trace = this_profiles(randIdx(j),:);
        plot(this_trace+sep*i,'Color',[.7 .7 .7])
    end
    
    this_mean = nanmean(this_profiles);
    plot(this_mean+sep*i,'Color',this_cols{i},'LineWidth',2)
end

lims = [0 140];
xlabel('Time (s)')
set(gca,'XTick',[0 20 40])
set(gca,'XTickLabel',[-4 0 4])
plot([20 20],lims,'Color',[.7 .7 .7])
ylim(lims)
set(gca,'YTick',[30 60 90])
set(gca,'YTickLabel',{'Neg.','Low','Pos.'})

fpath = fullfile(p.out_dir,'figS3','motion_response_classes.svg');
saveas(gca,fpath,'svg')

%% plot peak latency
    
[~,maxIdx] = max(all_profiles(all_classes == 3,21:end)');
[~,minIdx] = min(all_profiles(all_classes == 1,21:end)');

figure('Position',[100 100 300 300])
hold on 
histogram(minIdx,'Normalization','Probability','FaceColor',this_cols{1})
histogram(maxIdx,'Normalization','Probability','FaceColor',this_cols{3})

xlabel('Peak Latency (s)')
ylabel('Probability')
xlim([0 20])

set(gca,'XTick',[0 5 10 15 20])
set(gca,'XTickLabel',0:4)

fpath = fullfile(p.out_dir,'figS3','peak_latency.svg');
saveas(gca,fpath,'svg')

%% plot symmetry index
lag = 10;

pos_cells = all_profiles(all_classes == 3,:);
pos_cells_fil = pos_cells(maxIdx<11,:);
maxIdx_fil = maxIdx(maxIdx<11);

neg_cells = all_profiles(all_classes == 1,:);
neg_cells_fil = neg_cells(minIdx<11,:);
minIdx_fil = minIdx(minIdx<11);
sym_ratio = [];

for i = 1:size(pos_cells_fil,1)
    peak = pos_cells_fil(i,20+maxIdx_fil(i));
    pre_peak = pos_cells_fil(i,20+maxIdx_fil(i)-lag);
    post_peak = pos_cells_fil(i,20+maxIdx_fil(i)+lag);
    sym_ratio(i,1) = (post_peak-pre_peak)/peak;
    
    peak = neg_cells_fil(i,20+minIdx_fil(i));
    pre_peak = neg_cells_fil(i,20+minIdx_fil(i)-lag);
    post_peak = neg_cells_fil(i,20+minIdx_fil(i)+lag);
    sym_ratio(i,2) = (post_peak-pre_peak)/peak;
end

figure('Position',[100 100 300 300])
hold on
histogram(sym_ratio(:,1),-2:0.1:2,'Normalization','Probability','FaceColor',this_cols{1})
histogram(sym_ratio(:,2),-2:0.1:2,'Normalization','Probability','FaceColor',this_cols{3})

xlabel('Symmetry Index')
ylabel('Probability')
xlim([-2 2])

plot([0 0],[0 .15],'k','LineWidth',2)

fpath = fullfile(p.out_dir,'figS3','symmetry_idx.svg');
saveas(gca,fpath,'svg')

