%% preparatory analyses

% Fig. S6: DR validation
disp([char(datetime('now')) ' starting a0_dr_validation']) %  
a0_dr_validation 

% Fig S7
disp([char(datetime('now')) ' starting a1_x1_ae_and_iti_speed']) %  
a1_x1_ae_and_iti_speed

disp([char(datetime('now')) ' starting a1_x2_quantify_gaging']) % 
a1_x2_quantify_gaging


%% main analyses

% Fig. 2
disp([char(datetime('now')) ' starting a1_basic_decoding_ae_iti']) %  17
a1_basic_decoding_ae_iti 

% Fig. 3 (excpet tone)
disp([char(datetime('now')) ' starting a2_removal_analysis']) % 30
a2_removal_analysis 

% Fig. 3 (tone)
disp([char(datetime('now')) ' starting a2_x3_identification_of_tone_dim']) % 24
a2_x3_1_identification_of_tone_dim 

% Fig. 4, 
% Fig. 5 (projections)
% Fig. S10
disp([char(datetime('now')) ' starting a3_subspace_decomposition']) % 6
a3_subspace_decomposition 

% Fig. 5 (decoding)
disp([char(datetime('now')) ' starting a4_0_eval_avoid_decoders_per_ses']) % 22
a4_0_eval_avoid_decoders_per_ses

% Fig. 6
disp([char(datetime('now')) ' starting a4_1_task_decoding']) % 21
a4_1_task_decoding

disp([char(datetime('now')) ' starting a4_2_trial_group_decoding']) % 17
a4_2_trial_group_decoding

disp([char(datetime('now')) ' starting a4_3_trial_group_projections_av2']) % 6
a4_3_trial_group_projections_av2

% Fig. S8 (tone already done above)
disp([char(datetime('now')) ' starting a2_x1_identification_of_motion_dims']) % 2
a2_x1_identification_of_motion_dims

disp([char(datetime('now')) ' starting a2_x2_1_identification_of_avoid_dims']) % 12
a2_x2_1_identification_of_avoid_dims 

disp([char(datetime('now')) ' starting a2_x2_2_avoid_decoder_weights']) % 26
a2_x2_2_avoid_decoder_weights 

disp([char(datetime('now')) ' starting a2_x3_2_tone_decoding_per_sub']) 
a2_x3_2_tone_decoding_per_sub 


%% tone signal analysis (Fig. 7)
a5_0_tone_proj_example_and_cc
a5_1_tone_modulation_analysis_action_start_vs_tone_end
a5_2_tone_modulation_analysis_t2_shuttles


