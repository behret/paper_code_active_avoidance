%%
clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

fpath = fullfile(p.data_dir,'subspace_decomposition_one_subspace');
load(fpath,'all_dims','all_qs')

fpath = fullfile(p.data_dir,'tone_dim_analysis');
saveFigs = 1;
saveData = 1;
dim = 5;

%% calc correlation between tone proj and tone on/off signal
ccs = [];
for rep = 1:size(all_dims,2)
    for sub = 1:p.nSubjects
        for ses = 1:p.nSessions
            proj = (traces{sub,ses}' * all_qs{rep}{sub}) * all_dims{rep};
            tone_trace = evs{sub,ses}(5,:);
            proj_trace = proj(:,dim);
            cc = corrcoef(tone_trace,proj_trace);
            ccs(rep,sub,ses) = cc(1,2);
        end
    end
end
   

%% get tone proj for example rep / sub / ses / window 

rep = 1;
sub = 4;
ses = 7;
win = [2001:5000]-400;

proj = (traces{sub,ses}' * all_qs{rep}{sub}) * all_dims{rep};
proj_trace = proj(win,dim);
tone_trace = evs{sub,ses}(5,win);

%%
if saveData
    save(fpath,'ccs','proj_trace','tone_trace')
end

%%
plots_a5_0
