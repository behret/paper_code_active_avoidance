[cols,alpha] = chooseColors;

%% get coding dims per subject by projecting dims back into cell spaces
coding_dims = {};
for rep = 1:length(all_dims)
    for sub = 1:p.nSubjects
        coding_dims{rep,sub} = all_qs{rep}{sub} * all_dims{rep};
    end
end

%% calc. normalized weight distributions and weight entropy per cell
for sub = 1:p.nSubjects
    cell_ps = [];
    cell_ws = [];
    % calc p as mean over reps
    for rep = 1:size(coding_dims,1)
        for ce = 1:length(coding_dims{rep,sub})
            this_w = abs(coding_dims{rep,sub}(ce,1:5));
            this_p = this_w/sum(this_w);
            cell_ws(rep,ce,:) = this_w;
            cell_ps(rep,ce,:) = this_p;
        end
    end
    mean_p = squeeze(mean(cell_ps));
    all_ps{sub} = mean_p;
    mean_w = squeeze(mean(cell_ws));
    all_ws{sub} = mean_w;
    
    % calc ent per cell using mean_ps
    ent = [];
    for ce = 1:length(coding_dims{rep,sub})
        this_p = mean_p(ce,:);
        ent(ce) = -sum(abs(this_p).*log2(abs(this_p)));
    end
    all_ents{sub} = ent';
end

ps = cat(1,all_ps{:});
ws = cat(1,all_ws{:});
ents = cat(1,all_ents{:});

%% plot weight distributions for example cells
[sorted,sortIdx] = sort(ents);
idx = [5 208 2000 3333];

this_cols{1} = [208 28 139]/255;
this_cols{2} = [241 182 218]/255;
this_cols{3} = [77 172 38]/255;
this_cols{4} = [184 255 134]/255;
this_cols{5} = [67 162 202]/255;

figure('Position',[100 100 500 300])
for i = 1:length(idx)
    subplot(2,2,i)
    hold on
    for j = 1:5
        b = bar(j,ps(sortIdx(idx(i)),j),'FaceColor',this_cols{j});
    end
    ylim([0 0.8])
    xlim([0 6])
    set(gca,'XTick',[])
    set(gca,'YTick',[0 .8])
    text(3.5,0.70,['Cell ' num2str(i)])
    text(3,0.60,['Ent. = ' num2str(round(ents(sortIdx(idx(i))),2))])
end

if saveFigs
    fpath = fullfile(p.out_dir,'fig4','weight_distribution_examples.svg');
    saveas(gca,fpath,'svg')
end

%% plot distribution of entropy values

% calc minimal and maximal possible entropy for interpretation
min_ent_p = [1 0 0 0 0];
min_ent = -nansum(abs(min_ent_p).*log2(abs(min_ent_p)));
max_ent_p = [.2 .2 .2 .2 .2];
max_ent = -sum(abs(max_ent_p).*log2(abs(max_ent_p)));

figure('Position',[100 100 600 300])
hold on
histogram(ents,[1.4:0.03:2.5],'FaceColor','k')
xlabel('Entropy_{norm. |w|}')
ylabel('Num. Cells')
xlim([1.4 2.4])
plot(sorted(idx),[400 400 400 400],'ok','MarkerFaceColor','k')
ylim([0 450])
plot([max_ent,max_ent],[0,450],'k--')

if saveFigs
    fpath = fullfile(p.out_dir,'fig4','weight_distribution_entropy.svg');
    saveas(gca,fpath,'svg')
end
