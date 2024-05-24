clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%% run DR and decoding procedure for different trial samples
fpath = fullfile(p.data_dir,'svm_reg');
saveData = 1;
saveFigs = 1;
n_rep = 80; 
aa_sessions = 3:9;
n_tr = 300; 
n_pc = 10;

accs = [];
dims = [];
cs = [0.0001 0.001 0.01 0.1 1 10 100 1000 10000];


for rep = 1:n_rep
    tic
    
    %% prepare data
    speed_control = 0;

    [av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
        prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);

    [q, trial_idx_ses, ~, ~, ~, ~] = dr_into_joint_subspace(p, av_trials_all, err_trials_all, trans_data_all_dr, n_pc);

    [av_trials, err_trials, av_trials_iti, err_trials_iti, av_trials_dr, err_trials_dr, trans_data_dr, tone_idx_cat] = ...
        organize_trials_ae_iti(p, av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, q, trial_idx_ses,...
        aa_sessions, trans_data_all_dr, tone_idx);

    %% get motion dims 
    spd_dims = get_speed_dims_task_balance(p,trans_data_all_dr,q);

    % project trial data into motion nullspace
    nullspace = null(spd_dims(:,1:2)');    
    av_trials_null = [];
    err_trials_null = [];
    av_trials_iti_null = [];
    err_trials_iti_null = [];
    for t = 1:size(av_trials,2) % loop over time as it's the same for a/e
        av_trials_null(:,t,:) = nullspace' * squeeze(av_trials(:,t,:));
        err_trials_null(:,t,:) = nullspace' * squeeze(err_trials(:,t,:));
        av_trials_iti_null(:,t,:) = nullspace' * squeeze(av_trials_iti(:,t,:));
        err_trials_iti_null(:,t,:) = nullspace' * squeeze(err_trials_iti(:,t,:));
    end

    %% get AE dim and accs using different values for C
    
    av_data = [];
    rand_idx = randperm(size(av_trials_null,3));
    for tr = 1:n_tr
        this_trial_idx = rand_idx(tr);
        if isempty(tone_idx_cat)
            max_idx = 20;
        else
            max_idx = find(tone_idx_cat(this_trial_idx,:),1,'last');
        end
        this_time_idx = randi(max_idx);
        this_av = av_trials_null(:,this_time_idx,this_trial_idx);
        av_data = cat(2,av_data,this_av);
    end

    err_data = [];
    rand_idx = randperm(size(err_trials_null,3));
    for tr = 1:n_tr
        this_trial_idx = rand_idx(tr);
        this_time_idx = randi(20);
        this_err = err_trials_null(:,this_time_idx,this_trial_idx);
        err_data = cat(2,err_data,this_err);
    end
            
    x_train = cat(1,av_data',err_data');
    t_train = cat(1,ones(size(av_data,2),1),zeros(size(err_data,2),1));

    for i = 1:length(cs)
        % train cv model and get accs
        Mdl_cv = fitcsvm(x_train,t_train, 'KernelFunction','linear','kFold',5, ...
            'Standardize',true,'BoxConstraint',cs(i)); 
        accs(rep,i) = 1-kfoldLoss(Mdl_cv);

        % single model for weight analyis
        Mdl = fitcsvm(x_train,t_train, 'KernelFunction','linear','Standardize',true, ...
            'BoxConstraint',cs(i)); 
        weights = Mdl.Beta;
        dims(rep,i,:) =  weights/norm(weights);
    end
  
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end


%% save
if saveData
    save(fpath,'accs','dims','cs','n_rep')
end

%% plot accs
% average over reps for every i
lims = [45 75];

figure('Position',[100 100 300 300])
hold on
sample_mean = mean(accs*100);
for t = 1:size(accs,2)
    acc_sorted = sort(accs(:,t)*100);
    if size(acc_sorted,1) ~= 80
        disp('Number of reps needs to be 80 for CIs')
    end
    ci_high(t) = acc_sorted(78);
    ci_low(t) = acc_sorted(3);           
end
plot(sample_mean,'Color','k','LineWidth',2)
x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
ci_data = [ci_low, fliplr(ci_high)];
fill(x_data, ci_data , 1,....
        'facecolor','k', ...
        'edgecolor','none', ...
        'facealpha', alpha,...
        'HandleVisibility','off');

ylabel('Accuracy (%)')
xlabel('C')
set(gca,'XTick',[1 5 9])
set(gca,'XTickLabel',{'10^{-4}','10^{0}','10^{4}'})
plot([5 5],lims,'--','Color',[.7 .7 .7])
ylim(lims)

if saveFigs
    fpath = ['C:\Users\Benjamin Ehret\Desktop\paper_figures\eps_files\fig_S5_decomposition\svm_reg_acc.svg'];
    saveas(gca,fpath,'svg')
end

%% calc ccs within reps, average over reps

ccs = [];
for rep = 1:n_rep
    for i = 1:length(cs)
        for j = 1:length(cs)
            cc = corrcoef(dims(rep,i,:),dims(rep,j,:));
            ccs(rep,i,j) = cc(1,2);
        end
    end
end

figure('Position',[100 100 300 300])
imagesc(squeeze(mean(ccs)),[0 1])
set(gca,'XTick',[1 5 9])
set(gca,'XTickLabel',{'10^{-4}','10^{0}','10^{4}'})
xlabel('C')
set(gca,'YTick',[1 5 9])
set(gca,'YTickLabel',{'10^{-4}','10^{0}','10^{4}'})
ylabel('C')


if saveFigs
    fpath = ['C:\Users\Benjamin Ehret\Desktop\paper_figures\eps_files\fig_S5_decomposition\svm_reg_dim.svg'];
    saveas(gca,fpath,'svg')
end
