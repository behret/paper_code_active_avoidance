clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;
speed_control = 0;
iti_control = 0;
%%
[av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,err_trials_full_all] = prepare_data_task_subspaces(p, traces, evs, bvs, tis,speed_control);

% copied code from DR function 
%[ q, cell_means,trial_idx_ses] = dr_one_subspace_task_concat(p,av_trials_all,err_trials_all,trans_data_all,n_pc);

av_trials = av_trials_all;
err_trials = err_trials_all;
trans_data = trans_data_all;


%% pool trials into tasks
% also do overall pooling of task indices here. we need task specific
% indices first for building task-specific trial averages. later we
% pool trials overall, which requires trial indices over all trials

task_sessions{1} = 3:4;
task_sessions{2} = 5:9;
trial_idx = {};
for sub = 1:p.nSubjects    
    for t = 1:2
        task_trials_av{sub,t} = cat(3,av_trials{sub,task_sessions{t}});
        task_trials_err{sub,t} = cat(3,err_trials{sub,task_sessions{t}});
        task_trials_trans{sub,t} = cat(3,trans_data{sub,task_sessions{t}});
    end
end

    %% calc trial avs
    for sub = 1:p.nSubjects        
        for t = 1:2
            t_avs_a{sub,t} = squeeze(nanmean(task_trials_av{sub,t},3));
            t_avs_e{sub,t} = squeeze(nanmean(task_trials_err{sub,t},3));
            t_avs_t{sub,t} = squeeze(nanmean(task_trials_trans{sub,t},3));
        end
    end
    
    % cat subjects
    datamat = {};
    for t = 1:2
        a_cat = cat(1,t_avs_a{:,t});
        e_cat = cat(1,t_avs_e{:,t});
        t_cat = cat(1,t_avs_t{:,t});
        datamat{t} = cat(2,a_cat,e_cat,t_cat);
    end
    % cat tasks
    y = cat(2,datamat{:});    


    %% do PCA to find cells with high weights for PC1
    
    cell_means = mean(y,2);
    y = y-cell_means;
    [u,s,v] = svd(y);
    [~,sortIdx] = sort(u(:,1),'descend');
    
    %figure
    %hold on
    %plot(y(sortIdx([1,3]),:)')
    
    %%
    sep1 = zeros(1,2)/0;
    sep2 = zeros(1,8)/0;

    ylims = [-3 12];
    
    figure('Position',[100 100 600 300])
    hold on
   
    ces = [4 1]
    
    for ce = 1:2
        this_av = y(sortIdx(ces(ce)),:);
        plot_trace = [sep2 this_av(1:20) sep1 this_av(21:40) sep2 this_av(41:60) sep1 this_av(61:80) sep2 this_av(81:120) sep2 ...
                     this_av(121:140) sep1 this_av(141:160) sep2 this_av(161:180) sep1 this_av(181:200) sep2 this_av(201:240) sep2];
        plot(plot_trace + (ce-1) * 8,'k','LineWidth',2)
    end
    
    % figure out alignment points
    aps = [13 45 63 95 128];
    aps = [aps 148 + aps];
    for i = 1:length(aps)
        plot([aps(i) aps(i)],ylims,'Color',[.7 .7 .7])
    end
    
    xlim([5 301])
    ylim(ylims)
    set(gca,'XColor','none')
    set(gca,'YColor','none')
    
    area([5 55],[100 100],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none','BaseValue',-5)
    area([55 105],[100 100],'FaceColor',cols(3,:),'FaceAlpha',.25,'LineStyle','none')
    area([105 153],[100 100],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none')
    area([153 203],[100 100],'FaceColor',cols(4,:),'FaceAlpha',alpha,'LineStyle','none')
    area([203 253],[100 100],'FaceColor',cols(4,:),'FaceAlpha',.25,'LineStyle','none')
    area([253 301],[100 100],'FaceColor',cols(4,:),'FaceAlpha',alpha,'LineStyle','none')
    
    %%
    if 1
        fpath = fullfile(p.out_dir,'figS6','event_average_examples.svg');
        saveas(gca,fpath,'svg')
    end

    