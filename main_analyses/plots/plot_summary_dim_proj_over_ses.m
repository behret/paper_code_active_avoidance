function [ output_args ] = plot_summary_dim_proj_over_ses(p, mean_proj_a, mean_proj_e, dim_vars_ses, dim_ves_ses, saveFigs,out_dir)


    n_dims = 5;
    lims = [-3 8];
    cols = chooseColors;

    rep_mean_a = squeeze(mean(cat(4,mean_proj_a{:}),4));
    rep_mean_e = squeeze(mean(cat(4,mean_proj_e{:}),4));
    rep_mean_dim_vars = squeeze(mean(cat(3,dim_vars_ses{:}),3));
    rep_mean_dim_ves = squeeze(mean(cat(3,dim_ves_ses{:}),3));

    figure('Position',[100 100 1500 700])
    for ses = 1:p.nSessions
        % project onto summary dims and calculate VE
        if any(ses == [1 10 11])
            av_col = [.6 .6 .6];
            err_col = [196 100 152]/256;
        else
            av_col = 'k';
            err_col = cols(2,:);
        end
        
        for i = 1:n_dims
            subplot(n_dims,11,ses + (i-1)*11)
            hold on
            sep = zeros(1,5)/0;
            % plot avoid
            plot_trace = squeeze(rep_mean_a(ses,i,:));
            plot_trace = [plot_trace(1:20)' sep plot_trace(21:40)'];
            plot(plot_trace,'Color',av_col,'LineWidth',2)
            % plot error
            plot_trace = squeeze(rep_mean_e(ses,i,:));
            plot_trace = [plot_trace(1:20)' sep plot_trace(21:40)'];
            plot(plot_trace,'Color',err_col,'LineWidth',2)
            
            plot([5 5],lims,'Color',[.7 .7 .7])
            plot([40 40],lims,'Color',[.7 .7 .7])
            xlim([0 45])
            
            ylim(lims)
            set(gca,'XTick',[])
            set(gca,'YTick',[])
        end
    end

    
    if saveFigs
        fpath = fullfile(out_dir,'figS10','coding_dim_proj_per_ses.svg');
        saveas(gca,fpath,'svg')
    end
    
 
    
    %% plot VE over sessions
    lims = [0 60];
    this_cols{1} = [208 28 139]/255;
    this_cols{2} = [241 182 218]/255;
    this_cols{3} = [77 172 38]/255;
    this_cols{4} = [184 255 134]/255;
    this_cols{5} = [67 162 202]/255;
    this_cols{6} = [.7 .7 .7];
    
    % plot for all VEs
    figure('Position',[100 100 300 300])
    hold on
    plot_dims = [1 2 3 4 5];
    for i = 1:length(plot_dims)
        plot(rep_mean_dim_ves(:,plot_dims(i)),'LineWidth',2,'Color',this_cols{i})
    end
    xlabel('Day')
    ylabel('Var. Expl. (%)')
    set(gca,'XTick',[1 11])
    xlim([0 12])
    ylim(lims)

    plot([1.5 1.5],lims,'Color',[.7 .7 .7])
    plot([4.5 4.5],lims,'Color',[.7 .7 .7])
    plot([9.5 9.4],lims,'Color',[.7 .7 .7])
    
    
    % quantify VE
    for rep = 1:length(dim_ves_ses)
        motion_ves = sum(dim_ves_ses{rep}(:,1:2),2);
        motion_ves_hab_ext(rep) = mean(motion_ves([1 10 11]));
        motion_ves_aa(rep) = mean(motion_ves(2:9));
        
        task_ves = sum(dim_ves_ses{rep}(:,3:5),2);
        task_ves_hab(rep) = mean(task_ves([1]));
        task_ves_aa(rep) = mean(task_ves(2:9));
    end
    
    mn_val = mean(motion_ves_hab_ext);
    sorted = sort(motion_ves_hab_ext);
    ci_vals = sorted([3,78]);
    dim_ves_over_time{1} = ['motion in hab/ext: ' num2str(round(mn_val,1)) ' CI: [' num2str(round(ci_vals(1),1)) ', ' num2str(round(ci_vals(2),1)) ']'];
    mn_val = mean(motion_ves_aa);
    sorted = sort(motion_ves_aa);
    ci_vals = sorted([3,78]);
    dim_ves_over_time{2} = ['motion in aa: ' num2str(round(mn_val,1)) ' CI: [' num2str(round(ci_vals(1),1)) ', ' num2str(round(ci_vals(2),1)) ']'];
    mn_val = mean(task_ves_hab);
    sorted = sort(task_ves_hab);
    ci_vals = sorted([3,78]);
    dim_ves_over_time{3} = ['av/tone in hab: ' num2str(round(mn_val,1)) ' CI: [' num2str(round(ci_vals(1),1)) ', ' num2str(round(ci_vals(2),1)) ']'];
    mn_val = mean(task_ves_aa);
    sorted = sort(task_ves_aa);
    ci_vals = sorted([3,78]);
    dim_ves_over_time{4} = ['av/tone in aa: ' num2str(round(mn_val,1)) ' CI: [' num2str(round(ci_vals(1),1)) ', ' num2str(round(ci_vals(2),1)) ']'];
    cellfun(@(x) disp(x),dim_ves_over_time)
    
    if saveFigs
        fpath = fullfile(out_dir,'fig5','coding_dim_ves_per_ses.svg');
        saveas(gca,fpath,'svg')
    end
    
    
    
    %% plot total variance per sessions
    lims = [0 5];
    
    % plot for all VEs
    figure('Position',[100 100 300 300])
    hold on
    plot_dims = [1 2 3 4 5];
    for i = 1:length(plot_dims)
        plot(rep_mean_dim_vars(:,plot_dims(i)),'LineWidth',2,'Color',this_cols{i})
    end
    xlabel('Day')
    ylabel('Dim. Varinace (a.u.)')
    set(gca,'XTick',[1 11])
    xlim([0 12])
    
    plot([1.5 1.5],lims,'Color',[.7 .7 .7])
    plot([4.5 4.5],lims,'Color',[.7 .7 .7])
    plot([9.5 9.4],lims,'Color',[.7 .7 .7])
    
    
    if saveFigs
        fpath = fullfile(out_dir,'fig5','coding_dim_vars_per_ses.svg');
        saveas(gca,fpath,'svg')
    end
    
end