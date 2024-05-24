%% plot removal time dependent
[cols,alpha] = chooseColors;
figure('Position',[100 100 300 300])
hold on

% set lims and labels
xlim([0 31])
set(gca,'XTick',[0:5:30])
set(gca,'XTickLabel',-1:5)
xlabel('Time (s)')
ylabel('Accuracy (%)')

%indicate tone start and action start 
plot([5 5],[40 90],'k','HandleVisibility','off')

this_cmap = winter;
this_cols{1} = 'k';
this_cols{2} = this_cmap(1,:);
this_cols{3} = this_cmap(25,:);

% removal_accs_time{rep,config}: dc_rep / time / iter
for i = 1:size(removal_accs_time{1},3)
    dc_means = cellfun(@(x) squeeze(mean(x(:,:,i))),removal_accs_time,'UniformOutput',false);
    rep_mean = mean(cat(1,dc_means{:}));
    plot(rep_mean*100,'Color',this_cols{i},'LineWidth',2)
end

if saveFigs
    fpath = fullfile(p.out_dir,'fig3','tone_removal_analysis.svg');
    saveas(gca,fpath,'svg')
end


%% plot mean acc and VE per dimension 
y_color = [44,162,95]/255;

figure('Position',[100 100 300 300])
hold on
% mean acc of time-dependent decoders
dc_means = cellfun(@(x) squeeze(mean(mean(x(:,6:end,:),2)))',removal_accs_time,'UniformOutput',false);
dc_means = cat(1,dc_means{:})*100;
deltas = dc_means - dc_means(:,1);
sample_mean = mean(deltas);
for t = 1:size(deltas,2)
    sorted = sort(deltas(:,t));
    if size(sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = sorted(78);
    ci_low(t) = sorted(3);           
end
plot(sample_mean,'Color','k','LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
ci_data = [ci_low, fliplr(ci_high)];
fill(x_data, ci_data , 1,...
        'facecolor','k', ...
        'edgecolor','none', ...
        'facealpha', 0.3);
ylim([-30 3])
xlim([0 4])
ylabel('\Delta Mean Acc. (%)')



yyaxis right
dc_means = cat(1,tone_dim_ves{:});
deltas = cumsum(dc_means(:,1:2)')';
deltas = -[zeros(size(deltas,1),1) deltas];
sample_mean = mean(deltas);
plot(sample_mean,'Color',y_color,'LineWidth',2)
for t = 1:size(deltas,2)
    sorted = sort(deltas(:,t));
    if size(sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = sorted(78);
    ci_low(t) = sorted(3);           
end
ci_data = [ci_low, fliplr(ci_high)];
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
fill(x_data, ci_data , 1,...
        'facecolor',y_color, ...
        'edgecolor','none', ...
        'facealpha', 0.3);
    
    
    
ylim([-100 10])
xlim([0 4])
ylabel('\Delta VE (%)')
xlabel('# Removed Dims.')
set(gca,'XTick',1:3)
set(gca,'XTickLabel',0:2)
set(gca,'ycolor',y_color)




if saveFigs
    fpath = fullfile(p.out_dir,'fig3','tone_removal_analysis_quant.svg');
    saveas(gca,fpath,'svg')
end

%% figure out numbers for text

% accuracy (we report the drop from to instead of reporting the delta)
dc_means = cellfun(@(x) squeeze(mean(mean(x(:,6:end,:),2)))',removal_accs_time,'UniformOutput',false);
dc_means = cat(1,dc_means{:})*100;
sample_mean = mean(dc_means);
for t = 1:size(dc_means,2)
    sorted = sort(dc_means(:,t));
    if size(sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = sorted(78);
    ci_low(t) = sorted(3);           
end
% print numbers
removal_acc_numbers = ['org accuracy: ' num2str(round(sample_mean(1),1)) ' CI:' num2str(round(ci_low(1),1)) ' ' num2str(round(ci_high(1),1)),...
                   '   1 dim removed: ' num2str(round(sample_mean(2),1)) ' CI:' num2str(round(ci_low(2),1)) ' ' num2str(round(ci_high(2),1))];
disp(removal_acc_numbers)



% VE
dc_means = cat(1,tone_dim_ves{:});
deltas = (dc_means(:,1:2)')';
sample_mean = mean(deltas);
for t = 1:size(deltas,2)
    sorted = sort(deltas(:,t));
    if size(sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = sorted(78);
    ci_low(t) = sorted(3);           
end
% print numbers for VE
ve_numbers = ['VE drop 1: ' num2str(round(sample_mean(1),1)) ' CI:' num2str(round(ci_low(1),1)) ' ' num2str(round(ci_high(1),1)) ...
          ,'   VE drop 2: ' num2str(round(sample_mean(2),1)) ' CI:' num2str(round(ci_low(2),1)) ' ' num2str(round(ci_high(2),1))];
disp(ve_numbers)

%% compare accs of time-independent decoder (evaluated per timestep) and time-dependent decoders 

ind_col = [44,162,95]/255;

figure('Position',[100 100 300 300])
hold on

% set lims and labels
xlim([0 31])
set(gca,'XTick',[0:5:30])
set(gca,'XTickLabel',-1:5)
xlabel('Time (s)')
ylabel('Accuracy (%)')

%indicate tone start and action start 
plot([5 5],[40 90],'k','HandleVisibility','off')


% TIME DEPENDENT
i = 1; % first removal iteration = decoding in original space
dc_means = cellfun(@(x) squeeze(mean(x(:,:,i))),removal_accs_time,'UniformOutput',false);
rep_mean = mean(cat(1,dc_means{:}));
plot(rep_mean*100,'Color','k','LineWidth',2)


% TIME IN-DEPENDENT
dc_means = cellfun(@(x) squeeze(mean(x)),eval_accs,'UniformOutput',false);
rep_mean = mean(cat(1,dc_means{:}));
plot(rep_mean*100,'Color',ind_col,'LineWidth',2)

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','time_dependent_vs_independent_decoders.svg');
    saveas(gca,fpath,'svg')
end


%% weight analysis

ccs = [];
for rep = 1:length(tone_weights)
    dc_rep_mean = squeeze(mean(tone_weights{rep}));
    for t1 = 1:size(dc_rep_mean,1)
        for t2 = 1:size(dc_rep_mean,1)
            cc = corrcoef(dc_rep_mean(t1,:),dc_rep_mean(t2,:));
            ccs(rep,t1,t2) = cc(1,2);
        end
    end
end

figure('Position',[100 100 300 300])
imagesc(squeeze(mean(ccs)),[-.3 1])
set(gca,'XTick',[0:5:30])
set(gca,'XTickLabel',-1:5)
set(gca,'YTick',[0:5:30])
set(gca,'YTickLabel',-1:5)
xlabel('Time (s)')
ylabel('Time (s)')

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','temporal_weight_analysis_tone.svg');
    saveas(gca,fpath,'svg')
end


%% plot effect of removal on acc of time-independent decoder and compare to random removal

rand_col = 'b';

figure('Position',[100 100 300 300])
hold on
% acc of time-independent decoder
dc_means = cellfun(@(x) squeeze(mean(x,2))',removal_accs,'UniformOutput',false);
dc_means = cat(1,dc_means{:})*100;
sample_mean = mean(dc_means);
for t = 1:size(dc_means,2)
    sorted = sort(dc_means(:,t));
    if size(sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = sorted(78);
    ci_low(t) = sorted(3);           
end
ci_data = [ci_low, fliplr(ci_high)];
plot(sample_mean,'k','LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
fill(x_data, ci_data , 1,....
        'facecolor','k', ...
        'edgecolor','none', ...
        'facealpha', 0.3);
    
    
% acc of rand control
dc_means = cellfun(@(x) squeeze(mean(x,2))',removal_accs_rand,'UniformOutput',false);
dc_means = cat(1,dc_means{:})*100;
sample_mean = mean(dc_means);
for t = 1:size(dc_means,2)
    sorted = sort(dc_means(:,t));
    if size(sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = sorted(78);
    ci_low(t) = sorted(3);           
end
ci_data = [ci_low, fliplr(ci_high)];plot(sample_mean,rand_col,'LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
fill(x_data, ci_data , 1,....
        'facecolor',rand_col, ...
        'edgecolor','none', ...
        'facealpha', 0.3);
    
ylim([40 90])
xlim([0 4])
ylabel('Accuracy (%)')
xlabel('# Dim. Removed')
set(gca,'XTick',1:3)
set(gca,'XTickLabel',0:2)

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','removal_decoding_dim_vs_rand.svg');
    saveas(gca,fpath,'svg')
end

