%% TODOs

%% create folders for all figs
p = params_2DAA;

% create folders for all figs
dir_paths = {p.out_dir};
for i = 1:7
    dir_paths{length(dir_paths)+1} = fullfile(p.out_dir,['fig' num2str(i)]);
end
for i = 1:10
    dir_paths{length(dir_paths)+1} = fullfile(p.out_dir,['figS' num2str(i)]);
end
for i = 1:length(dir_paths)
    if ~exist(dir_paths{i})
        mkdir(dir_paths{i})
    end
end

%% a0 (fig S6)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'dr_validation');
load(fpath)
saveFigs = 1;
plots_a0

% additionally plot example for event averages (fig S6)
plot_example_DR_event_averages

%% a1 (fig 2)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'basic_ae_with_spd_and_iti_control');
load(fpath)
saveFigs = 1;
plots_a1

%% a1_x1 (fig S7)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'av_vs_iti');
load(fpath)
saveFigs = 1;
plots_a1_x1

%% a1_x2 (fig S7)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'iti_gaging_analysis');
load(fpath)
saveFigs = 1;
plots_a1_x2

%% a2 (fig 3)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'removal_analysis_one_subspace');
load(fpath)
saveFigs = 1;
plots_a2

%% a2_x1 motion dims (fig S8)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'identification_of_motion_dims');
load(fpath)
saveFigs = 1;
plots_a2_x1

%% a2_x2_1 avoid dims (fig S8)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'identification_of_avoid_dims');
load(fpath,'all_time_accs','all_eval_accs','all_removal_accs','all_removal_accs_rand')
saveFigs = 1;
plots_a2_x2_1

%% a2_x2_2 avoid 1 dim weight analysis (fig S8)
clear 
p = params_2DAA;
fpath = fullfile(p.data_dir,'ae_decoding_weight_analysis');
load(fpath)
p = params_2DAA;
saveFigs = 1;
plots_a2_x2_2

%% a2_x2_3 avoid 1 dim per sub (fig S8)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'eval_avoid_decoders_per_sub');
load(fpath)
saveFigs = 1;
plots_a2_x2_3

%% a2_x3_1: tone dims (fig 3 / fig S8)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'identification_of_tone_dim');
load(fpath)
p = params_2DAA;
saveFigs = 1;
plots_a2_x3_1

%% a2_x3_2: tone decoding per sub (fig S8)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'tone_decoding_per_sub');
load(fpath)
saveFigs = 1;
plots_a2_x3_2

%% a3 (fig 4 / fig 5 / fig s10)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'subspace_decomposition_one_subspace');
load(fpath)
p = params_2DAA;
saveFigs = 1;

plot_summary_dim_projections( proj_a(:,1), proj_e(:,1), dim_ves(:,1),saveFigs,p.out_dir) % fig 4
plot_summary_dim_projections_iti( proj_a(:,2), proj_e(:,2), dim_ves(:,2),saveFigs,p.out_dir) % fig 4
plot_summary_dim_proj_over_ses(p, mean_proj_a, mean_proj_e, dim_vars_ses, dim_ves_ses,saveFigs,p.out_dir) % fig s10 / fig 5
plot_summary_dim_proj_over_ses_type(p, mean_proj_a, mean_proj_e, dim_vars_ses, dim_ves_ses,saveFigs,p.out_dir) % fig 5

%% a3_x1: analyze weights (fig 4)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'subspace_decomposition_one_subspace');
load(fpath,'all_dims','all_qs')
saveFigs = 1;
a3_x1_weight_analysis


%% a4_0 (fig 5)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'eval_avoid_decoders_per_ses');
load(fpath)
saveFigs = 1;
plots_a4_0

%% a4_1 (fig 6)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'task_decoding_single_dim');
load(fpath)
saveFigs = 1;
plots_a4_1

%% a4_2 (fig 6)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'single_dim_decoding_t2_trial_groups');
load(fpath)
saveFigs = 1;
plots_a4_2

%% a5_0 (fig 7)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'tone_dim_analysis');
load(fpath)
saveFigs = 1;
plots_a5_0

%% a5_1 (fig 7)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'tone_dim_drop_1');
load(fpath)
saveFigs = 1;
plots_a5_1

%% a5_2 (fig 7)
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'subspace_decomposition_one_subspace');
load(fpath)
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'traces')
saveFigs = 1;
a5_2_tone_modulation_analysis_t2_shuttles

%% ADDITIONAL FIGURES 


%% Fig 1
action_start_vs_tone_end
example_cells_spontaneous_activity
plot_alignment_example_cell

clear
p = params_2DAA;
saveFigs = 1;
fpath = fullfile(p.data_dir,'cell_map_data');
load(fpath)
plot_cell_map

response_profile_examples
shuttling_2daa
trial_responsive_cells

%% Fig S1
plot_trial_traces
transition_analysis

%% Fig S3
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'session_alignment_mses');
load(fpath)
plot_quantify_alignment_quality

motion_artifact_control

clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'neuropil_analysis');
load(fpath)
plot_neuropil_analysis 

%% Fig S4
clear
p = params_2DAA;
fpath = fullfile(p.data_dir,'annotation_quantification');
load(fpath)
plot_quantify_annotation 

clear
p = params_2DAA;
plot_annotation_examples

%% Fig S5
plot_all_response_profiles_one_ses_z_score

%% Fig S9
activity_vs_behavior_per_sub