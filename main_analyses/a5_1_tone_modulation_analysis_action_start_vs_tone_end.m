% compare the tone component for different trial types and aligments:
%   1) avoid vs. error at tone end
%   2) avoid (action start) vs. error (tone end)
% - comparison 1 should show that in avoid trials tone singal drops early
% - comparison 2 should show that the drop is alinged between a and e 
% - this will allow us to argue that action init has some relation to tone
% coding...
% - to show that this is not related to motion we can show that there's no
% moldulation of the tone signal for outside transitions

clear
p = params_2DAA;
fpath = fullfile(p.processed_data_dir,'allData.mat');
load(fpath,'evs','tis','bvs','traces')
[cols,alpha] = chooseColors;

fpath = fullfile(p.data_dir,'subspace_decomposition_one_subspace');
load(fpath)

fpath = fullfile(p.data_dir,'tone_dim_drop_1');
saveFigs = 1;
saveData = 1;

%% calc scale factors per subject
for sub = 1:p.nSubjects
    all_tr = cat(2,traces{sub,:});
    vars(sub) = nanstd(all_tr(:));
end
scale_factors = 1./(vars / max(vars));

for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        traces{sub,ses} = traces{sub,ses}.*scale_factors(sub);
    end
end

%% get ae trials for action start alignment and tone end alignment
tone_start_control = 0; 
speed_control = 0;

[ av_trials_start,err_trials_start] = collect_ae_trials_for_tone_analysis(p, traces, bvs, tis, speed_control,1);
[ av_trials_action,err_trials_start] = collect_ae_trials_for_tone_analysis(p, traces, bvs, tis, speed_control,2);
[ av_trials_end,err_trials_start] = collect_ae_trials_for_tone_analysis(p, traces, bvs, tis, speed_control,3);

%%
action_vals = [];
tone_vals = [];

for rep = 1:10%length(all_dims)
    tic
    dims = all_dims{rep};
    q = all_qs{rep};

    % project trials into subspace
    t_pool_av_start = [];
    t_pool_av_action = [];
    t_pool_av_end = [];

    for sub = 1:p.nSubjects
        for ses = 3:9
            if any(ses == p.alignment.exclude{sub})
                continue
            end
            % project tone start
            for tr = 1:size(av_trials_start{sub,ses},3)
                this_tr = av_trials_start{sub,ses}(:,:,tr);
                this_proj = this_tr' * q{sub};
                t_pool_av_start = cat(3,t_pool_av_start,this_proj');
            end

            % project action start
            for tr = 1:size(av_trials_action{sub,ses},3)
                this_tr = av_trials_action{sub,ses}(:,:,tr);
                this_proj = this_tr' * q{sub};
                t_pool_av_action = cat(3,t_pool_av_action,this_proj');
            end

            % project tone end
            for tr = 1:size(av_trials_end{sub,ses},3)
                this_tr = av_trials_end{sub,ses}(:,:,tr);
                this_proj = this_tr' * q{sub};
                t_pool_av_end = cat(3,t_pool_av_end,this_proj');
            end
        end
    end
    
    % project trials into tone_dim and plot means
    this_dim = 5;

    tone_proj_av_start = [];
    for tr = 1:size(t_pool_av_start,3)
        this_proj = dims(:,this_dim)' * t_pool_av_start(:,:,tr);
        tone_proj_av_start = cat(1,tone_proj_av_start,this_proj);
    end

    tone_proj_action = [];
    for tr = 1:size(t_pool_av_action,3)
        this_proj = dims(:,this_dim)' * t_pool_av_action(:,:,tr);
        tone_proj_action = cat(1,tone_proj_action,this_proj);
    end

    tone_proj_av_end = [];
    for tr = 1:size(t_pool_av_end,3)
        this_proj = dims(:,this_dim)' * t_pool_av_end(:,:,tr);
        tone_proj_av_end = cat(1,tone_proj_av_end,this_proj);
    end

    % concat and add sep for discontinuity
    sep = zeros(1,10)/0;
    action_full = cat(2,nanmean(tone_proj_av_start),sep,nanmean(tone_proj_action));
    tone_full = cat(2,nanmean(tone_proj_av_start),sep,nanmean(tone_proj_av_end));
    
    action_vals = cat(1,action_vals,action_full);
    tone_vals = cat(1,tone_vals,tone_full);
end

%%
if saveData
    save(fpath,'action_vals','tone_vals')
end

%%
plots_a5_1
