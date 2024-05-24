% - collect data per subject and session (so we can individually analyze them later)
%   - av_trials 
%   - er_trials
%   - trans_data (fastest iti transitions, used for decoding)
%   - trans_data_err (random iti periods)
%   - trans_data_dr (remaining iti transitions, used for definition of spd dims)
% - DR: use half of avoid and error trials (specified in trial_idx_ses) and trans_data_dr
%   - input: all trials 
%   - output: projection matrices into subspace & trial_idx_ses which specifies which trials were used for DR
% - organize_trials:
%   - concat trials over subjects and sessions
%   - project trials into subspace

