% do basic decoding for 4 different settings:
% neural vs. speed
% a/e vs. iti

clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%%
fpath = fullfile(p.data_dir,'av_vs_iti');
saveFigs = 1;
saveData = 1;
aa_sessions = 3:9;
n_pc = 10;
speed_control = 1;


%%%
% We dont really need to run over multiple repetitions as were using all
% trials here. the only thing that is sampled is the error trials alignment
% but I think we can ignore that here. 
%%%


%% get data 
[av_trials_all, err_trials_all, trans_data_all, trans_data_err_all, err_trials_full_all, trans_data_all_dr, tone_idx] = ...
    prepare_data_task_subspaces(p, traces, evs, bvs, tis, speed_control);

% concat data from different sessions and subjects
av_trials = [];
err_trials = [];
av_trials_iti = [];
err_trials_iti = [];
for sub = 1:p.nSubjects    
    av_trials = cat(3,av_trials,av_trials_all{sub,aa_sessions});
    err_trials = cat(3,err_trials,err_trials_all{sub,aa_sessions});
    av_trials_iti = cat(3,av_trials_iti,trans_data_all{sub,aa_sessions});
    err_trials_iti = cat(3,err_trials_iti,trans_data_err_all{sub,aa_sessions});
end

% CUT TIME (different for ae and iti)
av_trials = av_trials(:,21:40,:);
err_trials = err_trials(:,21:40,:);
av_trials_iti = av_trials_iti(:,6:25,:);
err_trials_iti = err_trials_iti(:,6:25,:);

%% run UMAP

labs = [ones(1,size(av_trials,3)) 2*ones(1,size(err_trials,3)) ...
    3*ones(1,size(av_trials_iti,3)) 4*ones(1,size(err_trials_iti,3))];

data = cat(2,reshape(av_trials,[size(av_trials,1)*size(av_trials,2),size(av_trials,3)]),...
            reshape(err_trials,[size(err_trials,1)*size(err_trials,2),size(err_trials,3)]),...
            reshape(av_trials_iti,[size(av_trials_iti,1)*size(av_trials_iti,2),size(av_trials_iti,3)]),...
            reshape(err_trials_iti,[size(err_trials_iti,1)*size(err_trials_iti,2),size(err_trials_iti,3)]))';

reduction = {};
for rep = 1:10     
    [reduction{rep},~,~,~] = run_umap(data,'verbose','none');
end


%% save data
if saveData
    save(fpath,'reduction','av_trials','err_trials','av_trials_iti','err_trials_iti','labs')
end

%%
plots_a1_x1