function [ output_args ] = plot_summary_dim_proj_over_ses_type(p, mean_proj_a, mean_proj_e, dim_vars_ses, dim_ves_ses, saveFigs,out_dir)

%%
    lims = [-3 8];
    n_dims = 5;
    cols = chooseColors;
    rep_mean_a = squeeze(mean(cat(4,mean_proj_a{:}),4));
    rep_mean_e = squeeze(mean(cat(4,mean_proj_e{:}),4));
    rep_mean_dim_vars = squeeze(mean(cat(3,dim_vars_ses{:}),3));
    rep_mean_dim_ves = squeeze(mean(cat(3,dim_ves_ses{:}),3));

    
    figure('Position',[100 100 400 700])
    for ses_type = 1:4
        if ses_type == 1
            sessions = 1;
            av_col = [.6 .6 .6];
            err_col = [196 100 152]/256;
        elseif ses_type == 2
            sessions = 3:4;
            av_col = 'k';
            err_col = cols(2,:);
        elseif ses_type == 3
            av_col = 'k';
            err_col = cols(2,:);
            sessions = 6:9;        
        elseif ses_type == 4
            sessions = 10:11;  
            av_col = [.6 .6 .6];
            err_col = [196 100 152]/256;
        end
        
        this_proj_a = squeeze(mean(rep_mean_a(sessions,:,:),1));
        this_proj_e = squeeze(mean(rep_mean_e(sessions,:,:),1));

        for i = 1:n_dims
            subplot(5,4,ses_type + (i-1)*4)
            hold on
            
            sep = zeros(1,5)/0;
            % plot avoid
            plot_trace = squeeze(this_proj_a(i,:));
            plot_trace = [plot_trace(1:20) sep plot_trace(21:40)];
            plot(plot_trace,'Color',av_col,'LineWidth',2)
            % plot error
            plot_trace = squeeze(this_proj_e(i,:));
            plot_trace = [plot_trace(1:20) sep plot_trace(21:40)];
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
        fpath = fullfile(out_dir,'fig5','coding_dim_proj_per_ses_type.svg');
        saveas(gca,fpath,'svg')
    end

    
end