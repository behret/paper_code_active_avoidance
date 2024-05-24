clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

%% run DR and decoding procedure for different trial samples
fpath = fullfile(p.data_dir,'subspace_decomposition_one_subspace');
saveData = 1;
saveFigs = 1;
n_rep = 80; % ~25 sec. per rep
n_iter = 2;
n_dc_rep_time_independent = 10;
rand_control = 0;
aa_sessions = 3:9;
% default number of trials
n_tr = 300; 
n_pc = 10;

all_qs = {};
all_dims = {};

proj_a = {};
proj_e = {};
dim_ves = {};

mean_proj_a = {};
mean_proj_e = {};
dim_vars_ses = {};
dim_ves_ses = {};
dps = {};
dps_ses = {};

mean_proj_iti = {};
dim_vars_ses_iti = {};
dim_ves_ses_iti = {};

for rep = 1:n_rep
    tic
    
    %% do decomposition via script
    decomposition_script;
    all_qs{rep} = q;     
    all_dims{rep} = dims;
    
    %% project t_avs on summary dims
    % get full av and err trials (including tone start)
    [ av_trials, err_trials, av_trials_iti, err_trials_iti] = ...
        get_full_ae_trials_in_subspace(p, av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,q,trial_idx_ses,aa_sessions);
    
    [proj_a{rep,1},proj_e{rep,1},dim_ves{rep,1},dps{rep,1}] = project_tavs_onto_coding_dims(dims,av_trials,err_trials);
    [proj_a{rep,2},proj_e{rep,2},dim_ves{rep,2},dps{rep,2}] = project_tavs_onto_coding_dims(dims,av_trials_iti,err_trials_iti);
    
    %% analyze dims per session
    [mean_proj_a{rep},mean_proj_e{rep},dim_vars_ses{rep},dim_ves_ses{rep},dps_ses{rep}] = ...
        analyze_dims_over_sessions(p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,dims,q,trial_idx_ses);

    [mean_proj_iti{rep},dim_vars_ses_iti{rep},dim_ves_ses_iti{rep}] = ...
        analyze_dims_over_sessions_iti(p,av_trials_all,err_trials_all,trans_data_all,trans_data_err_all,dims,q,trial_idx_ses);
    
    %%
    if rep == 1
        t = round(toc);
        disp([char(datetime('now')) '    First iteration: ' num2str(t) 's. Estimated time: ' num2str((t*n_rep)/60) 'min / ' num2str((t*n_rep)/60/60) 'h'])
    end
end

% save
if saveData
    clear traces
    save(fpath)
end


%% plot projectios of subspace trial averages onto coding dimensions 
plot_summary_dim_projections( proj_a(:,1), proj_e(:,1), dim_ves(:,1),saveFigs)

%% plot coding dim projections for ITI shuttles
plot_summary_dim_projections_iti( proj_a(:,2), proj_e(:,2), dim_ves(:,2),saveFigs)

%% plot dims over sessions
plot_summary_dim_proj_over_ses(p, mean_proj_a, mean_proj_e, dim_vars_ses, dim_ves_ses,saveFigs)

%% plot dims per ses type
plot_summary_dim_proj_over_ses_type(p, mean_proj_a, mean_proj_e, dim_vars_ses, dim_ves_ses,saveFigs)

