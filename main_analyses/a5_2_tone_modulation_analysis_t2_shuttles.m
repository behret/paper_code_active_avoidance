% - analysis of tone-action interaction in 2DAA (drop in tone signal with 
% action start)
% - this came out very nicely in the 2TAA experiment (CS1 shuttles in T2)
% - for 2DAA we have a similar situation: at the start of task 2 animals
% perform d1 shuttles, but tone is not shut off
% - collect error trials for session 5 where animals performed a d1
% shuttle
% - project these trials into the tone subspace, sort them according to
% action start and plot 


%% 

% choose data from one rep
rep = 1;
nd = 5;
dims = all_dims{rep};
q = all_qs{rep};

[ shuttles,no_shuttles,shuttle_times ] = get_t2_d1_shuttles(p, traces, evs, bvs, tis, speed_control,0);


%%

t_pool = [];
for sub = 1:p.nSubjects
    % project trials
    for tr = 1:size(shuttles{sub},3)
        this_tr = shuttles{sub}(:,:,tr);
        this_proj = this_tr' * q{sub};
        t_pool = cat(3,t_pool,this_proj');
    end
end
all_times = cat(2,shuttle_times{:});


tone_proj = [];
for tr = 1:size(t_pool,3)
    this_proj = dims(:,nd)' * t_pool(:,:,tr);
    tone_proj = cat(1,tone_proj,this_proj);
end

[all_times,sortIdx] = sort(all_times);
tone_proj = tone_proj(sortIdx,:);

%
figure('Position',[100 100 300 300])
imagesc(tone_proj);
set(gca,'XTick',[25 50 75])
set(gca,'XTickLabel',[0 5 10])
xlabel('time (s)')
ylabel('trials')
colormap gray

if saveFigs
    fpath = fullfile(p.out_dir,'fig7','tone_dim_task2_d1_shuttles.svg');
    saveas(gca,fpath,'svg')
end



% plot aligned to shuttle start

% align at shuttle time
tp_shut = zeros(size(tone_proj,1),size(tone_proj,2)+50);
% used for averaging later (ignoring timepoints where tone was not present)
tp_shut_nans = zeros(size(tone_proj,1),size(tone_proj,2)+50);
for tr = 1:size(tone_proj,1)
    tp_shut(tr,1+(50-all_times(tr)):(50-all_times(tr))+size(tone_proj,2)) = tone_proj(tr,:);
end
% restrict to timepoints 10s around shuttle
tp_shut = tp_shut(:,26:125);


figure('Position',[100 100 300 300])
imagesc(tp_shut);
set(gca,'XTick',[25 50 75])
set(gca,'XTickLabel',[-5 0 5])
xlabel('time from shuttle start(s)')
ylabel('trials')
colormap gray

if saveFigs
    fpath = fullfile(p.out_dir,'fig7','tone_dim_task2_d1_shuttles_action_aligned.svg');
    saveas(gca,fpath,'svg')
end


%% plot mean tone proj (over trials and reps)
mean_tp_shuttle = [];
mean_tp_tone_start = [];
mean_tp_tone_end = [];

for rep = 1:length(all_dims)
    dims = all_dims{rep};
    q = all_qs{rep};
    
    % do projection and structuring 
    for config = 1:2
        if config == 2
            t_pool = [];
            for sub = 1:p.nSubjects
                % project trials
                for tr = 1:size(no_shuttles{sub},3)
                    this_tr = no_shuttles{sub}(:,:,tr);
                    this_proj = this_tr' * q{sub};
                    t_pool = cat(3,t_pool,this_proj');
                end
            end
            all_times = cat(2,shuttle_times{:});
            min_tr_num = min(size(all_times,2),size(t_pool,3));
            all_times = all_times(1:min_tr_num);
            t_pool = t_pool(:,:,1:min_tr_num);
            % randomize shuttle time
            all_times = all_times(randperm(size(all_times,2)));
        else
            t_pool = [];
            for sub = 1:p.nSubjects
                % project trials
                for tr = 1:size(shuttles{sub},3)
                    this_tr = shuttles{sub}(:,:,tr);
                    this_proj = this_tr' * q{sub};
                    t_pool = cat(3,t_pool,this_proj');
                end
            end
            all_times = cat(2,shuttle_times{:});
        end


        tone_proj = [];
        for tr = 1:size(t_pool,3)
            this_proj = dims(:,nd)' * t_pool(:,:,tr);
            tone_proj = cat(1,tone_proj,this_proj);
        end


        [all_times,sortIdx] = sort(all_times);
        tone_proj = tone_proj(sortIdx,:);

        % align at shuttle time
        tp_shut = zeros(size(tone_proj,1),size(tone_proj,2)+50);
        % used for averaging later (ignoring timepoints where tone was not present)
        tp_shut_nans = zeros(size(tone_proj,1),size(tone_proj,2)+50);
        for tr = 1:size(tone_proj,1)
            tp_shut(tr,1+(50-all_times(tr)):(50-all_times(tr))+size(tone_proj,2)) = tone_proj(tr,:);
        end
        % restrict to timepoints 10s around shuttle
        tp_shut = tp_shut(:,26:125);

        pad = 10;
        fil = all_times < pad | all_times > 50-pad;
        mean_tp_shuttle(rep,:,config) = mean(tp_shut(~fil,50-pad+1:50+pad));
        mean_tp_tone_start(rep,:,config) = mean(tone_proj(~fil,25-pad+1:25+pad));
        mean_tp_tone_end(rep,:,config) = mean(tone_proj(~fil,75-pad+1:75+pad));
    end
end

% take rep mean
tp_shuttle = squeeze(mean(mean_tp_shuttle));
tp_tone_start = squeeze(mean(mean_tp_tone_start));
tp_tone_end = squeeze(mean(mean_tp_tone_end));



%%
this_cols = {'k',cols(2,:)};

lims = [-2 6];
figure('Position',[100 100 200 300])
hold on
for i = 1:2
    plot(tp_tone_start(:,i),'Color',this_cols{i},'LineWidth',2)
end
ylim(lims)
plot([10 10],lims,'Color',[.7 .7 .7])
set(gca,'XTick',[0 10 20])
set(gca,'XTickLabel',[-2 0 2])
%set(gca,'YTick',[])
xlabel('time (s)')
if saveFigs
    fpath = fullfile(p.out_dir,'fig7','trial_av_tone_start.svg');
    saveas(gca,fpath,'svg')
end


figure('Position',[100 100 200 300])
hold on
for i = 1:2
    plot(tp_shuttle(:,i),'Color',this_cols{i},'LineWidth',2)
end
ylim(lims)
plot([10 10],lims,'Color',[.7 .7 .7])
set(gca,'XTick',[0 10 20])
set(gca,'XTickLabel',[-2 0 2])
set(gca,'YTick',[])
set(gca,'YColor','none')
xlabel('time (s)')
if saveFigs
    fpath = fullfile(p.out_dir,'fig7','trial_av_shuttle_start.svg');
    saveas(gca,fpath,'svg')
end


figure('Position',[100 100 200 300])
hold on
for i = 1:2
    plot(tp_tone_end(:,i),'Color',this_cols{i},'LineWidth',2)
end
ylim(lims)
plot([10 10],lims,'Color',[.7 .7 .7])
set(gca,'XTick',[0 10 20])
set(gca,'XTickLabel',[-2 0 2])
set(gca,'YTick',[])
set(gca,'YColor','none')
xlabel('time (s)')
if saveFigs
    fpath = fullfile(p.out_dir,'fig7','trial_av_tone_end.svg');
    saveas(gca,fpath,'svg')
end


%%
% calculate baseline value to get ratio right
baseline_shift = -mean2(mean_tp_tone_start(:,1:9,:));

ratios = [];
for t = 1:size(mean_tp_shuttle,2)
    ratios(:,t) = (mean_tp_shuttle(:,t,1)+baseline_shift) ./ (mean_tp_shuttle(:,t,2)+baseline_shift);
end

[~,min_idx] = min(mean(ratios));
min_ratio = 1-ratios(:,min_idx); 
sorted = sort(min_ratio);
mean_val = mean(min_ratio)*100;
ci_vals = sorted([3 78])'*100;
tone_signal_drop_number = ['drop ' num2str(min_idx-10) ' timesteps after action start:' num2str(round(mean_val,1)) ' CI:[' num2str(round(ci_vals(1),1)) ' ' num2str(round(ci_vals(2),1)) ']'];
disp(tone_signal_drop_number)