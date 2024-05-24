%%
clear
p = params_2DAA;
[cols,alpha] = chooseColors;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'tis','bvs')


%% did the animal perform a v or h shuttle in a given trial?
% we only consider the time up to shutoff!

transitions = zeros(p.nSubjects,p.nSessions,50,2);

for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        for tr = 1:50
            start = tis{sub,ses}(1,tr);
            stop = start + 50-1;
            qs = bvs{sub,ses}(5,start:stop);
            qdiff = [0 diff(qs)];
            transition_times = find(qdiff ~= 0); % find all transitions
            transition_types = qdiff(transition_times); % type (left right up down = 1 2 3 4)
            
            lr = 0;
            tlr = 100;
            ud = 0; 
            tud = 100;
            % was there a lr or ud transition and when were they?
            for t = 1:length(transition_times)
                if abs(transition_types(t)) == 1
                    ud = 1;
                    if transition_times(t) < tud
                        tud = transition_times(t);
                    end
                elseif abs(transition_types(t)) == 2
                    lr = 1;
                    if transition_times(t) < tlr
                        tlr = transition_times(t);
                    end
                elseif abs(transition_types(t)) == 3
                    lr = 1;
                    ud = 1;                    
                    if transition_times(t) < tud
                        tud = transition_times(t);
                    end
                    if transition_times(t) < tlr
                        tlr = transition_times(t);
                    end
                end
            end
            
            % in task 1 we only count ud shuttles if they came before lr
            % shuttles
            if tis{sub,ses}(5,tr) == 1 
                if tud > tlr
                    ud = 0;
                end
            end
            % in task 2 we only count lr shuttles if they came before ud
            % shuttles           
            if tis{sub,ses}(5,tr) == 2
                if tud < tlr
                    lr = 0;
                end
            end           
             
            % we only count transitions before shutoff
            transitions(sub,ses,tr,1) = lr;
            transitions(sub,ses,tr,2) = ud;
        end
    end
end

%%

figure('Position',[100 100 300 300],'Renderer','painters')
hold on

tr_mean = squeeze(mean(transitions,3))*100;

% plot lr shuttle
line_specs = {'-','--'};
for i = 1:2
    sample_mean = mean(tr_mean(:,:,i));
    sem = std(tr_mean(:,:,i)) / sqrt(size(tr_mean,1));

    plot(sample_mean,['k' line_specs{i}],'LineWidth',2)
    x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
    sem_data = [sample_mean-sem, fliplr(sample_mean+sem)];
    fill(x_data, sem_data , 1,....
            'facecolor','k', ...
            'edgecolor','none', ...
            'facealpha', 0.3);
end
       
xlim([0.5 11.5])
ylim([0 100])
xlabel('Days')
ylabel('Shuttle Rate (%)')
set(gca,'XTick',[1 5 11])

area([0 1.5],[100 100],'FaceColor',cols(1,:),'FaceAlpha',alpha,'LineStyle','none')
area([1.5 4.5],[100 100],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none')
area([4.5 9.5],[100 100],'FaceColor',cols(4,:),'FaceAlpha',alpha,'LineStyle','none')
area([9.5 11.5],[100 100],'FaceColor',cols(5,:),'FaceAlpha',alpha,'LineStyle','none')

%%
fpath = fullfile(p.out_dir,'fig1','shuttling.svg');
saveas(gca,fpath,'svg')
%% print numbers

% avoid in T1
d1_ses2 = mean(tr_mean(:,2,1));
d1_ses2_sem = std(tr_mean(:,2,1)) / sqrt(size(tr_mean,1));
avoid_ses2 = ['Avoid ses2: ' num2str(round(d1_ses2)) '+-' num2str(round(d1_ses2_sem))];
d1_ses4 = mean(tr_mean(:,4,1));
d1_ses4_sem = std(tr_mean(:,4,1)) / sqrt(size(tr_mean,1));
avoid_ses4 = ['Avoid ses4: ' num2str(round(d1_ses4)) '+-' num2str(round(d1_ses4_sem))];

% avoid in T2
d2_ses5 = mean(tr_mean(:,5,2));
d2_ses5_sem = std(tr_mean(:,5,2)) / sqrt(size(tr_mean,1));
avoid_ses5 = ['Avoid ses5: ' num2str(round(d2_ses5)) '+-' num2str(round(d2_ses5_sem))];
d2_ses9 = mean(tr_mean(:,9,2));
d2_ses9_sem = std(tr_mean(:,9,2)) / sqrt(size(tr_mean,1));
avoid_ses9 = ['Avoid ses9: ' num2str(round(d2_ses9)) '+-' num2str(round(d2_ses9_sem))];

% x shuttle freq change from 4 to 9
d1_ses9 = mean(tr_mean(:,9,1));
d1_ses9_sem = std(tr_mean(:,9,1)) / sqrt(size(tr_mean,1));
x_ses4 = ['X ses4: ' num2str(round(d1_ses4)) '+-' num2str(round(d1_ses4_sem))];
x_ses9 = ['X ses9: ' num2str(round(d1_ses9)) '+-' num2str(round(d1_ses9_sem))];

% y shuttle freq change from 4 to 9
d2_ses4 = mean(tr_mean(:,4,2));
d2_ses4_sem = std(tr_mean(:,4,2)) / sqrt(size(tr_mean,1));
y_ses4 = ['Y ses4: ' num2str(round(d2_ses4)) '+-' num2str(round(d2_ses4_sem))];
y_ses9 = ['Y ses9: ' num2str(round(d2_ses9)) '+-' num2str(round(d2_ses9_sem))];

behavior_numbers = {avoid_ses2,avoid_ses4,avoid_ses5,avoid_ses9,x_ses4,x_ses9,y_ses4,y_ses9};
cellfun(@(x) disp(x),behavior_numbers)


%% make figure for avoidance only
figure('Position',[100 100 300 300],'Renderer','painters')
hold on

tr_mean = squeeze(mean(transitions,3))*100;

tr_mean_av = tr_mean(:,:,1);
tr_mean_av(:,5:9) = tr_mean(:,5:9,2);
tr_mean_av(:,[1 10 11]) = nan;

% plot avoid
sample_mean = mean(tr_mean_av);
sem = std(tr_mean_av) / sqrt(size(tr_mean_av,1));

plot(sample_mean,'k','LineWidth',2)
x_data = [2:9 fliplr(2:9)];
sem_data = [sample_mean(2:9)-sem(2:9), fliplr(sample_mean(2:9)+sem(2:9))];
fill(x_data, sem_data , 1,....
        'facecolor','k', ...
        'edgecolor','none', ...
        'facealpha', 0.3);

       
xlim([1.5 9.5])
ylim([0 100])
xlabel('Days')
ylabel('Avoidance Rate (%)')
set(gca,'XTick',2:9)

area([0 1.5],[100 100],'FaceColor',cols(1,:),'FaceAlpha',alpha,'LineStyle','none')
area([1.5 4.5],[100 100],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none')
area([4.5 9.5],[100 100],'FaceColor',cols(4,:),'FaceAlpha',alpha,'LineStyle','none')
area([9.5 11.5],[100 100],'FaceColor',cols(5,:),'FaceAlpha',alpha,'LineStyle','none')

%%
fpath = fullfile(p.out_dir,'fig1','avoidance.svg');
saveas(gca,fpath,'svg')