%%
[cols,alpha] = chooseColors;

t_cols = {};
this_cmap = winter;
t_cols{1} = 'k';
t_cols{2} = [1 0.5 0];
t_cols{3} = this_cmap(64,:);

%% plot subject VE
figure('Position',[100 100 300 300])

hold on
this_cols = {t_cols{1},t_cols{2},t_cols{3}};

all_ves = cat(3,subject_ves{:});

sample_mean = mean(cat(3,subject_ves{:}),3)';
sample_sd = std(cat(3,subject_ves{:}),[],3)'; 

for i = 1:2 % 3 to include shuffle PCA + QR
    
    this_ves = squeeze(all_ves(:,i,:));
    sample_mean = mean(this_ves,2)';
    plot(sample_mean,'Color',this_cols{i},'LineWidth',2)
    x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
    for pc = 1:size(this_ves,1)
        sorted = sort(this_ves(pc,:))';
        if size(sorted,1) ~= 80
            disp('Number of reps needs to be 80 for CIs')
        end
        ci_high(pc) = sorted(78);
        ci_low(pc) = sorted(3);        
    end
    ci_data = [ci_low, fliplr(ci_high)];
    fill(x_data, ci_data , 1,....
            'facecolor',this_cols{i}, ...
            'edgecolor','none', ...
            'facealpha', .4,...
            'HandleVisibility','off');
end

xlim([0 21])
ylim([0 100])

ylabel('Mean VE per Sub. (%)')
xlabel('Dimensions')
plot([10 10],[0 100],'--','Color',[.5 .5 .5])


if saveFigs
    fpath = fullfile(p.out_dir,'figS6','ve_per_sub.svg');
    saveas(gca,fpath,'svg')
end

%% plot dimension similarity (between dims)
rep_mean = squeeze(mean(cat(4,dim_sims{:}),4));

for i = [1]
    figure('Position',[100 100 300 300])
    imagesc(squeeze(rep_mean(:,:,i)),[0 1])
    ylabel('Dimensions')
    xlabel('Dimensions')
end

if saveFigs
    fpath = fullfile(p.out_dir,'figS6','dim_similarity_matrix.svg');
    saveas(gca,fpath,'svg')
end

%% plot dim similarity CIs

this_cols = t_cols;

figure('Position',[100 100 300 300])
for i = 1:3
    diags = [];
    for r = 1:size(dim_sims,2)
        diags(r,:) = diag(squeeze(dim_sims{r}(:,:,i)));
    end

    hold on
    sample_mean = mean(diags);    
    for t = 1:size(diags,2)
        d_sorted = sort(diags(:,t));
        if size(d_sorted,1) ~= 80
            disp('Number of reps needs to be 80 for CIs')
        end
        ci_high(t) = d_sorted(78);
        ci_low(t) = d_sorted(3);              
    end
    
    plot(sample_mean,'Color',this_cols{i},'LineWidth',2)
    x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
    ci_data = [ci_low, fliplr(ci_high)];
    fill(x_data, ci_data , 1,....
            'facecolor',this_cols{i}, ...
            'edgecolor','none', ...
            'facealpha', .4,...
            'HandleVisibility','off');
end
    
ylabel('Mean Dim. Similiarity')
xlabel('Dimensions')
plot([10 10],[0 100],'--','Color',[.5 .5 .5])
ylim([-.1 1])

if saveFigs
    fpath = fullfile(p.out_dir,'figS6','dim_similarity_diags.svg');
    saveas(gca,fpath,'svg')
end

%% plot between subject similarity for example dim from example rep
dim = 1;
for rep = 2%:5
    ccs_example_dim = [];
    for sub1 = 1:p.nSubjects
        for sub2 = 1:p.nSubjects
            cc = corrcoef(projs{rep}(sub1,:,dim), projs{rep}(sub2,:,dim));
            ccs_example_dim(sub1,sub2) = cc(1,2);
        end
    end

    figure('Position',[100 100 300 300])

    pd = ccs_example_dim;
    pd(tril(pd) ~= 0) = nan;

    imagesc(pd,[0 1])
    ylabel('Subjects')
    xlabel('Subjects')

    cmap = parula;
    cmap(1,:) = [1 1 1];
    colormap(cmap)
end

if saveFigs
    fpath = fullfile(p.out_dir,'figS6','dim_similarity_example.svg');
    saveas(gca,fpath,'svg')
end


%% plot projections of individual subjects

for rep = 1%:10
    figure('Position',[100 100 1400 350])
    for pc = 1:10
        subplot(2,10,pc)
        hold on

        % plot mean proj for avoid trials
        this_mat = squeeze(projs{rep}(:,:,pc));
        sample_mean = mean(this_mat);
        if max(sample_mean) < -min(sample_mean)
            this_mat = - this_mat;
            sample_mean = mean(this_mat);
        end
        sem = std(this_mat) / sqrt(size(this_mat,1));
        plot(sample_mean,'Color','k','LineWidth',2)
        x_data = [1:length(sample_mean) fliplr(1:length(sample_mean))];
        sem_data = [sample_mean-sem, fliplr(sample_mean+sem)];
        fill(x_data, sem_data , 1,....
                'facecolor','k', ...
                'edgecolor','none', ...
                'facealpha', .4,...
                'HandleVisibility','off');

        % shades to indicate structure of concatenated trial avs
        area([0 40],[100 100],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none','BaseValue',-5)
        area([40 80],[100 100],'FaceColor',cols(3,:),'FaceAlpha',.25,'LineStyle','none')
        area([80 120],[100 100],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none')
        area([120 160],[100 100],'FaceColor',cols(4,:),'FaceAlpha',alpha,'LineStyle','none')
        area([160 200],[100 100],'FaceColor',cols(4,:),'FaceAlpha',.25,'LineStyle','none')
        area([200 240],[100 100],'FaceColor',cols(4,:),'FaceAlpha',alpha,'LineStyle','none')
            
            
        if pc == 0
            ylabel('projection (a.u.)')
        else
            set(gca,'YTick',[]) 
        end
        %title(['Dim. ' num2str(pc)])

        xlim([0 size(this_mat,2)])
        ylim([-5 12])
        set(gca,'XTick',[]) 
        
        % plot for all subs
        subplot(2,10,10+pc)
        this_proj = this_mat;

        if any(pc == [1 2])
            clims = [-5 10];
        elseif any(pc == [3 4])
            clims = [-5 5];
        else
            clims = [-3 3];
        end

        imagesc(this_proj,clims)
        if pc == 1
            ylabel('Subjects')
        else
            set(gca,'YTick',[]) 
        end
        %set(gca,'XTick',[1 40 80 120]) 
        %set(gca,'XTickLabel',[0 8 16 24])
        set(gca,'XTick',[]) 
    end
end

if saveFigs
    fpath = fullfile(p.out_dir,'figS6','validation_per_dim.svg');
    saveas(gca,fpath,'svg')
end
