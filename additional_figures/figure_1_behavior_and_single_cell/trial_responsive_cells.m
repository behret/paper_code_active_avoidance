

%% load data
clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'tis','bvs','traces','evs')
[cols,alpha] = chooseColors;
z_cutoff = 1.96;
saveFigs = 1;


%% add action start to TIs for non-aa sessions
for sub = 1:p.nSubjects
    for ses = [1 10 11]
        spd_diff = diff([bvs{sub,ses}(23,:) 0]);
        for tr = 1:50
           if tis{sub,ses}(3,tr) == 0
                shuttle = tis{sub,ses}(1,tr) + tis{sub,ses}(6,tr);
                % action start alignment using speed
                this_win = shuttle-10:shuttle;
                [~,max_diff_idx] = max(spd_diff(this_win));
                dt_start = 11-max_diff_idx;
                rel_start = tis{sub,ses}(6,tr)-dt_start;
                % in case actions start before tone start, set the
                % action start to 1
                if rel_start < 1
                    rel_start = 1;
                end
                tis{sub,ses}(12,tr) = rel_start;
            end
        end
    end
end


%%
% - get trial averages per session
% - use all trials (except for too short trials, which is less than 15)
% - get 3 periods: 
%   30 before tone as baseline (same length as profile)
%   15 after tone start
%   15 before action start

pad_pre = 30;
tr_win = 15;
bl_avs = {};
profiles = {};
for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        trials_bl = [];
        trials_tone = [];
        trials_shuttle = [];

        for tr = 1:50
            % collect all avoid trials
            if tis{sub,ses}(3,tr) == 0 && tis{sub,ses}(12,tr) > 15
                
                % get before tone start
                ap = tis{sub,ses}(1,tr);
                win = ap - pad_pre: ap-1;
                this_tr = traces{sub,ses}(:,win);
                trials_bl = cat(3,trials_bl,this_tr); 
                
                % get cutouts aligned to tone start
                ap = tis{sub,ses}(1,tr);
                win = ap : ap + tr_win-1;
                this_tr = traces{sub,ses}(:,win);
                trials_tone = cat(3,trials_tone,this_tr);

                % get cutouts aligned to shuttle start
                ap = tis{sub,ses}(1,tr) + tis{sub,ses}(12,tr);
                win = ap - tr_win: ap - 1;
                this_tr = traces{sub,ses}(:,win);
                trials_shuttle = cat(3,trials_shuttle,this_tr);
            end
        end
        
        % calc trial average
        bl_avs{sub,ses} = nanmean(trials_bl,3);
        profiles{sub,ses} = [nanmean(trials_tone,3) nanmean(trials_shuttle,3)];
    end
end


%% based on trials avs, compute z score
trial_z = {};
mean_z = {};
for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        bl_mean = mean(bl_avs{sub,ses},2);
        bl_std = std(bl_avs{sub,ses},[],2);
        trial_z{sub,ses} = (profiles{sub,ses} - bl_mean)./bl_std;
        mean_z{sub,ses} = mean(trial_z{sub,ses},2);
    end
end


%% plot fractions of cells over sessions
cell_frac = [];
for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        if sum(isnan(mean_z{sub,ses})) == 0
            cell_frac(sub,ses) = sum(abs(mean_z{sub,ses}) > z_cutoff)/length(mean_z{sub,ses})*100;
        else
            cell_frac(sub,ses) = nan;
        end
    end
end

figure('Position',[100 100 300 300],'Renderer','painters')
hold on

sample_mean = nanmean(cell_frac);
sem = nanstd(cell_frac) / sqrt(size(cell_frac,1));
plot(sample_mean,'color','k','LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
sem_data = [sample_mean-sem, fliplr(sample_mean+sem)];
fill(x_data, sem_data , 1,....
        'facecolor','k', ...
        'edgecolor','none', ...
        'facealpha', 0.3);
 
xlim([0.5 11.5])
xlabel('days')
ylabel({'% trial-responsive','cells'})
set(gca,'XTick',[1 11])

area([0 1.5],[80 80],'FaceColor',cols(1,:),'FaceAlpha',alpha,'LineStyle','none')
area([1.5 4.5],[80 80],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none')
area([4.5 9.5],[80 80],'FaceColor',cols(4,:),'FaceAlpha',alpha,'LineStyle','none')
area([9.5 11.5],[80 80],'FaceColor',cols(5,:),'FaceAlpha',alpha,'LineStyle','none')

if saveFigs
    fpath = fullfile(p.out_dir,'fig1','trial_responsive_cells.svg');
    saveas(gca,fpath,'svg')
end

% print number for text: mean for hab / aa / ext sessions
hab_mn = sample_mean(1);
hab_sem = sem(1);

aa_mn = mean(sample_mean(2:9));
aa_sem = mean(sem(2:9));

ext_mn = mean(sample_mean(10:11));
ext_sem = mean(sem(10:11));

responsive_cells_numbers{1} = ['Hab: ' num2str(round(hab_mn)) '+-' num2str(round(hab_sem))];
responsive_cells_numbers{2} = ['AA: ' num2str(round(aa_mn)) '+-' num2str(round(aa_sem))];
responsive_cells_numbers{3} = ['Ext: ' num2str(round(ext_mn)) '+-' num2str(round(ext_sem))];
cellfun(@(x) disp(x),responsive_cells_numbers)



%% overlap of trial responsive cells

overlaps = [];
for sub = 1:p.nSubjects
    
    trial_cells = [];
    for ses = 1:p.nSessions
        if ~isempty(mean_z{sub,ses})
            trial_cells(:,ses) = abs(mean_z{sub,ses}) > z_cutoff;
        else
            trial_cells(:,ses) = zeros(size(mean_z{sub,1},1),1);
        end
    end
        
    for ses1 = 1:p.nSessions
        for ses2 = 1:p.nSessions
            if any(ses1 == p.alignment.exclude{sub}) || any(ses2 == p.alignment.exclude{sub})
                overlaps(sub,ses1,ses2) = nan;
            else
                n_cells = sum(trial_cells(:,ses1) == 1) +  sum(trial_cells(:,ses2) == 1);
                common_cells = sum(trial_cells(:,ses1) == 1 & trial_cells(:,ses2) == 1);
                overlaps(sub,ses1,ses2) = common_cells / (n_cells/2);
            end
        end
    end
end

figure('Position',[100 100 300 300])
imagesc(squeeze(nanmean(overlaps)),[0 1])
set(gca,'XTick',[1 11])
set(gca,'YTick',[1 11])
xlabel('days')
ylabel('days')

if saveFigs
    fpath = fullfile(p.out_dir,'fig1','cell_overlaps.svg');
    saveas(gca,fpath,'svg')
end

% calc mean over aa sessions
for sub = 1:p.nSubjects
    aa_ses = squeeze(overlaps(sub,2:9,2:9));
    aa_vals = tril(aa_ses);
    aa_vals = aa_vals(:);
    aa_vals(aa_vals == 0 | aa_vals == 1) = [];
    aa_means(sub) = mean(aa_vals);
end
aa_mn = nanmean(aa_means)*100;
aa_sem = nanstd(aa_means)/sqrt(p.nSubjects)*100;

% for ext there's only one value
ext_mn = nanmean(overlaps(:,10,11))*100;
ext_sem = nanstd(overlaps(:,10,11))/sqrt(p.nSubjects)*100;

overlap_numbers{1} = ['AA: ' num2str(round(aa_mn)) '+-' num2str(round(aa_sem))];
overlap_numbers{2} = ['Ext: ' num2str(round(ext_mn)) '+-' num2str(round(ext_sem))];
cellfun(@(x) disp(x),overlap_numbers)
