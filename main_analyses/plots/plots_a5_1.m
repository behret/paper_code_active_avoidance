%% quantify and plot
[cols,alpha] = chooseColors;

% calc mean over reps
action_full = mean(action_vals);
tone_full = mean(tone_vals);

% restrict to end period
action_end = action_full(41:70);
tone_end = tone_full(41:70);

% find timepoint with maximal drop for action start / tone end alignment
[~,max_drop_action] = min(diff([action_end]));
[~,max_drop_tone] = min(diff([tone_end]));

% make relative to alignment point
max_drop_action_rel = max_drop_action - 15;
max_drop_tone_rel = max_drop_tone - 15;
% for plotting
max_drop_action_plot = max_drop_action + 40;
max_drop_tone_plot = max_drop_tone + 40;


lims = [-2 6];
% action alignment
figure('Position',[100 100 300 300])
hold on
plot(action_full,'k','LineWidth',2)
set(gca,'XTick',[0 15 30 40 55 70]) 
set(gca,'XTickLabel',[-3 0 3 -3 0 3])
xlabel('time (s)')
plot([15,15],lims,'Color',[.7 .7 .7])
plot([55,55],lims,'Color',[.7 .7 .7])
xlim([0 70])
ylabel('tone dim. activity (a.u.)')
% plot timing of max drop
plot(max_drop_action_plot,action_full(max_drop_action_plot),'m*','MarkerSize',10)


if saveFigs
    fpath = fullfile(p.out_dir,'fig7','tone_dim_action_start.svg');
    saveas(gca,fpath,'svg')
end

% tone alignment
figure('Position',[100 100 300 300])
hold on
plot(tone_full,'k','LineWidth',2)
set(gca,'XTick',[0 15 30 40 55 70]) 
set(gca,'XTickLabel',[-3 0 3 -3 0 3])
xlabel('time (s)')
plot([15,15],lims,'Color',[.7 .7 .7])
plot([55,55],lims,'Color',[.7 .7 .7])
xlim([0 70])
ylabel('tone dim. activity (a.u.)')
% plot timing of max drop
plot(max_drop_tone_plot,tone_full(max_drop_tone_plot),'m*','MarkerSize',10)

if saveFigs
    fpath = fullfile(p.out_dir,'fig7','tone_dim_tone_end.svg');
    saveas(gca,fpath,'svg')
end

disp(['max drop action: ' num2str(max_drop_action_rel)])
disp(['max drop tone: ' num2str(max_drop_tone_rel)])