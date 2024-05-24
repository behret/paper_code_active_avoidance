function [ output_args ] = plot_summary_dim_projections( proj_a, proj_e, dim_ves, saveFigs,out_dir )


    %% plot projections per dim
    cols = chooseColors;    
    lims = [-2.5 7.5];

    rep_mean_a = squeeze(mean(cat(3,proj_a{:}),3));
    rep_mean_e = squeeze(mean(cat(3,proj_e{:}),3));
    rep_mean_ve = squeeze(mean(cat(1,dim_ves{:}),1));

    n_dims = 5; 

    figure('Position',[100 100 1500 300])
    for nd = 1:n_dims
        subplot(1,n_dims,nd)
        hold on

        ylim(lims)
        xlim([0 46])
        set(gca,'XTick',[5 20 25 40]) 
        set(gca,'XTickLabel',[0 3 -3 0])
        xlabel('time (s)')
        plot([5,5],lims,'Color',[.7 .7 .7])
        plot([40,40],lims,'Color',[.7 .7 .7])

        % add sep for discontinuity
        sep = zeros(5,1)/0;
        a_plt = [rep_mean_a(1:20,nd); sep ;rep_mean_a(21:40,nd)];
        e_plt = [rep_mean_e(1:20,nd); sep ;rep_mean_e(21:40,nd)];

        plot(a_plt,'k','LineWidth',2)
        plot(e_plt,'Color',cols(2,:),'LineWidth',2)

        %title(['VE: ' num2str(round(rep_mean_ve(nd),2)) '%'])

        if nd == 1
            ylabel('projection (a.u.)')
        end
    end
    
    if saveFigs
        fpath = fullfile(out_dir,'fig4','coding_dim_projections.svg');
        saveas(gca,fpath,'svg')
    end
    
    
    
    %% plot distribution of VEs
    % exchange PC2 var with 'residual var'
    dim_ves_total = dim_ves;
    for rep = 1:length(dim_ves_total)
        dim_ves_total{rep}(6) = 100 - sum(dim_ves_total{rep}(1:5));
    end

    rep_ves = cat(1,dim_ves_total{:});
    rep_ves = rep_ves(:,1:6);
    
    this_cols{1} = [208 28 139]/255;
    this_cols{2} = [241 182 218]/255;
    this_cols{3} = [77 172 38]/255;
    this_cols{4} = [184 255 134]/255;
    this_cols{5} = [67 162 202]/255;
    this_cols{6} = [.7 .7 .7];

    % box plot
    if 0 
        figure('Position',[100 100 300 300])

        boxplot(rep_ves)
        xlim([0 7])
        ylim([0 80])
        ylabel('Var. Expl. (%)')
        set(gca,'XTick',1:6)
        set(gca,'XTickLabel',{'Motion 1','Motion 2','Avoid 1','Avoid 2','Tone','Residual'})
        xtickangle(45)

        h = findobj(gca,'Tag','Box');
        for j=1:length(h)
            patch(get(h(j),'XData'),get(h(j),'YData'),this_cols{7-j},'FaceAlpha',.6);
        end
    end 
    
    % violin plot
    figure('Position',[100 100 300 300])
    hold on
    for d = 1:6
        this_ves = rep_ves(:,d);
        distributionPlot(this_ves,'color',[.9 .9 .9],'histOpt',1,'xValues',d,'showMM',0)
        % plot mean and CI
        sorted = sort(this_ves);
        if size(this_ves,1) ~= 80
            disp('Number of reps needs to be 80 for CIs')
        end
        ci_high = sorted(78);
        ci_low = sorted(3);    
        this_mean = mean(this_ves);
        plot(d,this_mean,'o','color',this_cols{d},'MarkerFaceColor',this_cols{d})
        errorbar(d,this_mean,this_mean-ci_low,this_mean-ci_high,'color',this_cols{d})
    end
    xlim([0 7])
    ylim([0 85])
    ylabel('Var. Expl. (%)')
    set(gca,'XTick',1:6)
    set(gca,'XTickLabel',{'Motion 1','Motion 2','Avoid 1','Avoid 2','Tone','Residual'})
    xtickangle(45)  
    
    if saveFigs
        fpath = fullfile(out_dir,'fig4','coding_dim_ves_violin.svg');
        saveas(gca,fpath,'svg')
    end
    
    %% pie chart
    
    mean_total_ves = mean(rep_ves);
    figure('Position',[100 100 300 300])
    h = pie(mean_total_ves,{'','','','','',''});
    patchHand = findobj(h, 'Type', 'Patch'); 
    for i = 1:6
        patchHand(i).FaceColor = this_cols{i};
    end
    
    if saveFigs
        fpath = fullfile(out_dir,'fig4','coding_dim_ves_pie_chart.svg');
        saveas(gca,fpath,'svg')
    end

    %% print number for text
    ve_sum = sum(rep_ves(:,1:5)')';
    sorted = sort(ve_sum);
    ve_sum_mn = mean(ve_sum);
    ve_sum_ci = sorted([3,78])';
    dim_ve_numbers = ['VE of 5 dims: ' num2str(round(ve_sum_mn,1)) ' CI: [' num2str(round(ve_sum_ci(1),1)) ', ' num2str(round(ve_sum_ci(2),1)) ']'];
    disp(dim_ve_numbers);
    

    %% plot correlations between dims projections
            
    rep_mean_a = squeeze(mean(cat(3,proj_a{:}),3));
    rep_mean_e = squeeze(mean(cat(3,proj_e{:}),3));
    
    rep_mean_cat = cat(1,rep_mean_a,rep_mean_e)';
        
    n_dims = 5; 
    ccs = [];
    for rep = 1:length(proj_a)
        this_projs = cat(1,proj_a{rep},proj_e{rep})';
        for i = 1:n_dims
            for j = 1:n_dims
                cc = corrcoef(this_projs(i,:),this_projs(j,:));
                ccs(rep,i,j) = cc(1,2);
            end
        end
    end
    
    rep_mean = squeeze(mean(ccs));
    
    figure('Position',[100 100 300 300])
    imagesc(rep_mean,[.2 1])
    
    set(gca,'XTickLabel',{'M1','M2','AV1','AV2','T'})
    set(gca,'YTickLabel',{'M1','M2','AV1','AV2','T'})
    
    mean_cc_m_av = mean([rep_mean(1,2),rep_mean(1,3),rep_mean(1,4),rep_mean(2,3),rep_mean(2,4),rep_mean(3,4)]);
    std_cc_m_av = std([rep_mean(1,2),rep_mean(1,3),rep_mean(1,4),rep_mean(2,3),rep_mean(2,4),rep_mean(3,4)]);
    dim_cc_numbers = ['Mean corr. between motion and avoid dims.: ' num2str(round(mean_cc_m_av,2)) '+-' num2str(round(std_cc_m_av,2))];
    disp(dim_cc_numbers);
    
    if saveFigs
        fpath = fullfile(out_dir,'fig4','proj_corrs.svg');
        saveas(gca,fpath,'svg')
    end

    
end

