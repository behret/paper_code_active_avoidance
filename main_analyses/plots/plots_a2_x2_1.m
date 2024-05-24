%% compare accs of time-independent decoder (evaluated per timestep) and time-dependent decoders 
[cols,alpha] = chooseColors;
ind_col = [44,162,95]/255;

figure('Position',[100 100 300 300])
hold on

% set lims and labels
xlim([0 21])
set(gca,'XTick',[0 5 10 15 20])
set(gca,'XTickLabel',[-3 -2 -1 0 1])
xlabel('time (s)')
ylabel('accuracy (%)')

%indicate tone start and action start 
plot([15 15],[40 100],'k','HandleVisibility','off')

% TIME DEPENDENT
dc_means = squeeze(mean(all_time_accs))';
rep_mean = mean(dc_means);
plot(rep_mean*100,'Color','k','LineWidth',2)

% TIME IN-DEPENDENT
dc_means = squeeze(mean(all_eval_accs))';
rep_mean = mean(dc_means);
plot(rep_mean*100,'Color',ind_col,'LineWidth',2)

if saveFigs
    fpath = fullfile(p.out_dir,'figS8','time_dependent_vs_independent_decoders_avoid.svg');
    saveas(gca,fpath,'svg')
end


%% plot effect of removal on acc of time-independent decoder and compare to random removal

rand_col = 'b';


figure('Position',[100 100 300 300])
hold on
% acc of time-independent decoder
dc_means = squeeze(mean(all_removal_accs,2))*100;
sample_mean = mean(dc_means);
for t = 1:size(dc_means,2)
    acc_sorted = sort(dc_means(:,t));
    if size(acc_sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = acc_sorted(78);
    ci_low(t) = acc_sorted(3);            
end
plot(sample_mean,'k','LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
ci_data = [ci_low, fliplr(ci_high)];
fill(x_data, ci_data , 1,....
        'facecolor','k', ...
        'edgecolor','none', ...
        'facealpha', 0.3);
    
    
% acc of rand control
dc_means = squeeze(mean(all_removal_accs_rand,2))*100;
sample_mean = mean(dc_means);
for t = 1:size(dc_means,2)
    acc_sorted = sort(dc_means(:,t));
    if size(acc_sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = acc_sorted(78);
    ci_low(t) = acc_sorted(3);       
end
plot(sample_mean,rand_col,'LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
ci_data = [ci_low, fliplr(ci_high)];
fill(x_data, ci_data , 1,....
        'facecolor',rand_col, ...
        'edgecolor','none', ...
        'facealpha', 0.3);
    
ylim([40 70])
xlim([0 6])
ylabel('accuracy (%)')
xlabel('# dim. removed')
set(gca,'XTick',1:5)
set(gca,'XTickLabel',0:4)


if saveFigs
    fpath = fullfile(p.out_dir,'figS8','removal_decoding_dim_vs_rand_avoid.svg');
    saveas(gca,fpath,'svg')
end

