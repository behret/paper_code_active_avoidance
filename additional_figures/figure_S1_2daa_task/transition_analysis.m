clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath)
[cols,alpha] = chooseColors;

%% find transitions and record some data about them

for sub = 1:p.nSubjects
    for ses = 1:p.nSessions

        % time
        qdiff = [0 diff(bvs{sub,ses}(5,:))];
        transition_times = find(abs(qdiff) == 2 | abs(qdiff) == 1); % find all transitions
        
        % type (left right up down = 1 2 3 4)
        transition_types = qdiff(transition_times);
        % map from -2 -1 1 2 to 1 2 3 4
        % remapping must be in this order to not mess things up
        transition_types(transition_types == 1) = 4; % down  
        transition_types(transition_types == -2) = 1; % left
        transition_types(transition_types == 2) = 2; % right 
        transition_types(transition_types == -1) = 3; % up 

        
        % was transition during or outside trial?
        % here we use definitions that are not exactly opposite:
        % - during trial is only until trial end
        % - outside trial is only in ITI (to exclude transitions that come
        % directly after trial end)
        during_trial = evs{sub,ses}(5,transition_times);
        outside_trial = evs{sub,ses}(1,transition_times) == 0;

        % shutoff: 1 if transition caused shutoff
        % transitions that caused a shutoff must be during the tone and
        % must have the right transition type
        if any(ses == 2:4)
            shutoff_types = transition_types == 1 | transition_types == 2;
        elseif any(ses == 5:9)
            shutoff_types = transition_types == 3 | transition_types == 4;
        else
            shutoff_types = transition_types == 0; % never...
        end
        
        shutoff_transitions = zeros(size(transition_times));
        if sum(shutoff_types > 0)
            for tr = 1:size(tis{sub,ses},2)
                if tis{sub,ses}(3,tr) == 0
                    toneWin = tis{sub,ses}(1,tr) : tis{sub,ses}(1,tr)+50;
                    % these transitions would end the tone, but we only take
                    % the first one if there's multiple
                    correct_transitions = intersect(toneWin,transition_times(shutoff_types));
                    if ~isempty(correct_transitions)
                        shutoff_time = correct_transitions(1);
                        trans_idx = find(transition_times == shutoff_time);
                        shutoff_transitions(trans_idx) = 1;
                    end
                end
            end
        end
        
        disp([sum(shutoff_transitions) sum(tis{sub,ses}(3,:)==0)])
        transitions{sub,ses} = [transition_times; transition_types; shutoff_transitions ; during_trial ; outside_trial];
    end
end

% filter for very early or very late transitions
pad_size = 10;
for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        early_idx = transitions{sub,ses}(1,:) <= pad_size*5;
        late_idx = length(evs{sub,ses}) - transitions{sub,ses}(1,:) <= pad_size*5;
        cut_idx = early_idx | late_idx;
        transitions{sub,ses} = transitions{sub,ses}(:,~cut_idx);
    end
end


%% plot total number of transitions 

n_lr = [];
n_ud = [];

for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        % total
        n_lr(sub,ses,1) = sum(transitions{sub,ses}(2,:) < 3);
        n_ud(sub,ses,1) = sum(transitions{sub,ses}(2,:) > 2);
        % during
        n_lr(sub,ses,2) = sum(transitions{sub,ses}(2,:) < 3 & transitions{sub,ses}(4,:) == 1);
        n_ud(sub,ses,2) = sum(transitions{sub,ses}(2,:) > 2 & transitions{sub,ses}(4,:) == 1);
        % outside
        n_lr(sub,ses,3) = sum(transitions{sub,ses}(2,:) < 3 & transitions{sub,ses}(5,:) == 1);
        n_ud(sub,ses,3) = sum(transitions{sub,ses}(2,:) > 2 & transitions{sub,ses}(5,:) == 1);
    end
end


%% plot relative to time
n_lr_rel = [];
n_ud_rel = [];

for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        
        trial_time = sum(evs{sub,ses}(5,:)) / (5*60);
        no_trial_time = sum(evs{sub,ses}(5,:) == 0) / (5*60);
        
        % during
        n_lr_rel(sub,ses,1) = n_lr(sub,ses,2) / trial_time;
        n_ud_rel(sub,ses,1) = n_ud(sub,ses,2) / trial_time;
        % outside
        n_lr_rel(sub,ses,2) = n_lr(sub,ses,3) / no_trial_time;
        n_ud_rel(sub,ses,2) = n_ud(sub,ses,3) / no_trial_time;
    end
end

% T1
figure('Position',[100 100 300 300])
hold on
% during
sample_mean = mean(n_lr_rel(:,:,1));
sem = std(n_lr_rel(:,:,1)) / sqrt(size(n_lr_rel,1));
plot(sample_mean,'Color',cols(3,:),'LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
sem_data = [sample_mean-sem, fliplr(sample_mean+sem)];
fill(x_data, sem_data , 1,....
        'facecolor',cols(3,:), ...
        'edgecolor','none', ...
        'facealpha', 0.3);
    
% outside
sample_mean = mean(n_lr_rel(:,:,2));
sem = std(n_lr_rel(:,:,2)) / sqrt(size(n_lr_rel,1));
plot(sample_mean,'Color','k','LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
sem_data = [sample_mean-sem, fliplr(sample_mean+sem)];
fill(x_data, sem_data , 1,....
        'facecolor','k', ...
        'edgecolor','none', ...
        'facealpha', 0.3);
    
xlim([0 12])
ylim([0 8])
xlabel('days')
ylabel('trans. freq. (1/min)')
set(gca,'XTick',[1 11])
    
fpath = fullfile(p.out_dir,'figS1','transition_freq_t1.svg');
saveas(gca,fpath,'svg')


% T2
figure('Position',[100 100 300 300])
hold on
% during
sample_mean = mean(n_ud_rel(:,:,1));
sem = std(n_ud_rel(:,:,1)) / sqrt(size(n_ud_rel,1));
plot(sample_mean,'Color',cols(4,:),'LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
sem_data = [sample_mean-sem, fliplr(sample_mean+sem)];
fill(x_data, sem_data , 1,....
        'facecolor',cols(4,:), ...
        'edgecolor','none', ...
        'facealpha', 0.3);
    
% outside
sample_mean = mean(n_ud_rel(:,:,2));
sem = std(n_ud_rel(:,:,2)) / sqrt(size(n_ud_rel,1));
plot(sample_mean,'Color','k','LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
sem_data = [sample_mean-sem, fliplr(sample_mean+sem)];
fill(x_data, sem_data , 1,....
        'facecolor','k', ...
        'edgecolor','none', ...
        'facealpha', 0.3); 
    
xlim([0 12])
ylim([0 8])
xlabel('days')
ylabel('trans. freq. (1/min)')
set(gca,'XTick',[1 11])

fpath = fullfile(p.out_dir,'figS1','transition_freq_t2.svg');
saveas(gca,fpath,'svg')   
   
%% collect shutoff transitions and outside trial transitions

% task / inside vs outside / spd vs speed signal      
all_wins = cell(2,2);
sub_wins = cell(p.nSubjects,2,2);
for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
            
        % get speed windows
        wins = zeros(size(transitions{sub,ses},2),pad_size*2+1);
        for tr = 1:size(transitions{sub,ses},2)
            ttime = transitions{sub,ses}(1,tr);
            wins(tr,:) = bvs{sub,ses}(3,ttime-pad_size:ttime+pad_size);
        end
        
        % find shutoff transitions / outside transitions
        % only look at lr in T1 and ud in T2
        if any(ses == 2:4)
            dir_fil = transitions{sub,ses}(2,:) == 1 | transitions{sub,ses}(2,:) == 2;
            task = 1;
        elseif any(ses == 5:9)
            dir_fil = transitions{sub,ses}(2,:) == 3 | transitions{sub,ses}(2,:) == 4;
            task = 2;
        else
            continue
        end
        shutoff_idx = transitions{sub,ses}(3,:) == 1;
        outside_idx = transitions{sub,ses}(5,:) == 1 & dir_fil;
        
        all_wins{task,1} = cat(1,all_wins{task,1},wins(shutoff_idx,:));
        all_wins{task,2} = cat(1,all_wins{task,2},wins(outside_idx,:));

        sub_wins{sub,task,1} = cat(1,sub_wins{sub,task,1},wins(shutoff_idx,:));
        sub_wins{sub,task,2} = cat(1,sub_wins{sub,task,2},wins(outside_idx,:));
    end
end

  

%% mean speed distributions over transition

this_cols{1} = cols(3,:);
this_cols{2} = cols(4,:);

bins = 0:20;

for task = 1:2
    for i = 1:2
        for j = 1:2
            spd_score{i,j} = nanmean(all_wins{i,j}(:,5:15)*0.06,2);
        end
    end
    figure('Position',[100 100 300 300])
    histogram(spd_score{task,1},bins,'Normalization','probability','FaceColor',this_cols{task})
    hold on 
    histogram(spd_score{task,2},bins,'Normalization','probability','FaceColor','k')
    ylabel('Probability')
    xlabel('Mean Speed (cm/s)')

    fpath = fullfile(p.out_dir,'figS1',['transition_speed_distribution_t' num2str(task)]);
    saveas(gca,fpath,'svg')
end



%% plot mean speed for avoid and outside

for task = 1:2
    figure('Position',[100 100 300 300])
    hold on
    for i = 1:2
        
        if i == 2
            col = 'k';
        else
            col = this_cols{task};
        end
        
        sample_mean = mean(all_wins{task,i}*0.06);
        sample_std = std(all_wins{task,i}*0.06);
        plot(sample_mean,'color',col,'LineWidth',2)
        x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
        std_data = [sample_mean-sample_std, fliplr(sample_mean+sample_std)];
        fill(x_data, std_data , 1,....
                'facecolor',col, ...
                'edgecolor','none', ...
                'facealpha', 0.3);
        xlim([0 22])
        set(gca,'XTick',[1 6 11 16 21])
        set(gca,'XTickLabel',[-2 -1 0 1 2])
        xlabel('Time from Shuttle (s)') 
        ylabel('Speed (cm/s)')
    end
    ylim([-5 45])
    
    fpath = fullfile(p.out_dir,'figS1',['mean_transition_speed_t' num2str(task)]);
    saveas(gca,fpath,'svg')
end


