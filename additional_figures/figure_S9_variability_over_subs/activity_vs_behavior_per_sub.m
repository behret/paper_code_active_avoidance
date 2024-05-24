clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;
saveFigs = 1;
%% run DR and decoding procedure for different trial samples
%fpath = 'G:\SRM_results\one_subspace_task_decoding\subspace_decomposition_one_subspace';
%aveData = 1;
%saveFigs = 1;
n_rep = 2; % ~25 sec. per rep
n_iter = 2;
n_dc_rep_time_independent = 10;
rand_control = 0;
aa_sessions = 3:9;
% default number of trials
n_tr = 300; 
n_pc = 10;

projs_a = {};
projs_e = {};

projs_a_t2 = {};
projs_e_t2 = {};

for rep = 1:n_rep
    tic
    
    %% do decomposition via script
    decomposition_script;

    %% collect avoid data per subject
    for sub = 1:p.nSubjects    
        % collect all AA trials
        t_pool_a = [];
        t_pool_e = [];
        for ses = aa_sessions
            if ~isempty(av_trials_all{sub,ses})
                t_pool_a = cat(3,t_pool_a,av_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,1,2}));
            end
            if ~isempty(err_trials_all{sub,ses})
                t_pool_e = cat(3,t_pool_e,err_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,2,2}));
            end
        end
        p_single = p;
        p_single.nSubjects = 1;
        this_av_proj = project_trial_set_into_one_subspace(p_single,{t_pool_a},[],q(sub));
        t_av = nanmean(this_av_proj,3);
        projs_a{rep,sub} = (t_av' * dims)';
        this_err_proj = project_trial_set_into_one_subspace(p_single,{t_pool_e},[],q(sub));
        t_av = nanmean(this_err_proj,3);
        projs_e{rep,sub} = (t_av' * dims)';

        % collect T2 trials only for comparison to T2 shuttle angle
        t_pool_a = [];
        t_pool_e = [];
        for ses = 5:9 % restrict to T2!
            if ~isempty(av_trials_all{sub,ses})
                t_pool_a = cat(3,t_pool_a,av_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,1,2}));
            end
            if ~isempty(err_trials_all{sub,ses})
                t_pool_e = cat(3,t_pool_e,err_trials_all{sub,ses}(:,:,trial_idx_ses{sub,ses,2,2}));
            end
        end
        p_single = p;
        p_single.nSubjects = 1;
        this_av_proj = project_trial_set_into_one_subspace(p_single,{t_pool_a},[],q(sub));
        t_av = nanmean(this_av_proj,3);
        projs_a_t2{rep,sub} = (t_av' * dims)';
        this_err_proj = project_trial_set_into_one_subspace(p_single,{t_pool_e},[],q(sub));
        t_av = nanmean(this_err_proj,3);
        projs_e_t2{rep,sub} = (t_av' * dims)';
    end
end


%% plot all projections
cols = chooseColors;    
lims = [-4 11];
n_dims = 5; 

figure('Position',[100 100 1500 600])
for nd = 1:n_dims
    for i = 1:2
        subplot(2,n_dims,nd+n_dims*(i-1))
        hold on
        for sub = 1:p.nSubjects
            if i == 1
                rep_mean = squeeze(mean(cat(3,projs_a{:,sub}),3))';
            else
                rep_mean = squeeze(mean(cat(3,projs_e{:,sub}),3))';
            end

            % add sep for discontinuity
            sep = zeros(5,1)/0;
            plt_data = [rep_mean(1:20,nd); sep ;rep_mean(21:40,nd)];
            plot(plt_data)
        end
    
        ylim(lims)
        xlim([0 46])
        set(gca,'XTick',[5 20 25 40]) 
        set(gca,'XTickLabel',[0 3 -3 0])
        xlabel('Time (s)')
        plot([5,5],lims,'Color',[.7 .7 .7])
        plot([40,40],lims,'Color',[.7 .7 .7])
    
        if nd == 1
            ylabel('Projection (a.u.)')
        end
    end
end

if saveFigs
    fpath = fullfile(p.out_dir,'figS9','all_proj');
    saveas(gca,fpath,'svg')
end


%% relate activity in avoid dimensions to overall performance 
act_score = [];
perf = [];
for sub = 1:p.nSubjects
    rep_mean = squeeze(mean(cat(3,projs_a{:,sub}),3))';
    act_score(sub,:) = mean(rep_mean(21:35,1:5));
    
    aa_tr = cat(2,tis{sub,aa_sessions});
    perf(sub) = sum(aa_tr(3,:) == 0)/size(aa_tr,2);
end

figure('Position',[100 100 1200 200])
for i = 1:5
    subplot(1,5,i)
    scatter(act_score(:,i),perf,'ko','MarkerFaceColor','k')
    lsline
    ylim([0 1])
end

%% plots for figure (only avoid 1 and avoid 2)

is = [3,4];
xlabs = {'Avoid 1 Activity','Avoid 2 Activity'};
 
for i = 1:2
    figure('Position',[100 100 300 300])
    scatter(act_score(:,is(i)),perf*100,'ko','MarkerFaceColor','k')
    lsline
    ylim([0 100])
    xlabel(xlabs{i})
    ylabel('Performance (% Shuttles)')

    if saveFigs
        fpath = fullfile(p.out_dir,'figS9',['act_vs_perf_avoid' num2str(i) '.svg']);
        saveas(gca,fpath,'svg')
    end
    cc = corrcoef(perf,act_score(:,is(i)));
    disp(cc(1,2))
end

%% relate T2 activity in avoid dimensions to T2 shuttle angle
fpath = fullfile(p.data_dir,'shuttle_angles');
load(fpath)

act_score_t2 = [];
angles = [];
for sub = 1:p.nSubjects
    rep_mean = squeeze(mean(cat(3,projs_a_t2{:,sub}),3))';
    act_score_t2(sub,:) = mean(rep_mean(21:35,1:5)); 
    angles(sub) = mean(angles_t2{sub});
end

figure('Position',[100 100 1000 200])
for i = 1:5
    subplot(1,5,i)
    scatter(act_score_t2(:,i),angles,'ko','MarkerFaceColor','k')
    ylim([0,120])
    lsline
end

%% plots for figure (only avoid 1 and avoid 2)

is = [3,4];
xlabs = {'T2 Avoid 1 Activity','T2 Avoid 2 Activity'};
 
for i = 1:2
    figure('Position',[100 100 300 300])
    scatter(act_score_t2(:,is(i)),angles,'ko','MarkerFaceColor','k')
    lsline
    ylim([0 120])
    set(gca,'YTick',[0,30,60,90,120])
    xlabel(xlabs{i})
    ylabel('T2 Shuttle Angle (°)')

    if saveFigs
        fpath = fullfile(p.out_dir,'figS9',['act_vs_angle_avoid' num2str(i) '.svg']);
        saveas(gca,fpath,'svg')
    end
    cc = corrcoef(angles,act_score_t2(:,is(i)));
    disp(cc(1,2))
end