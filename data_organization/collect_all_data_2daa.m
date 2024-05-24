% clear
% organize_tracking_data()
% organize_nidaq_data()
%clear
%p = params_2DAA;
%organize_miniscope_data(p)
clear
p = params_2DAA;

%% load nidaq data
fpath = fullfile(p.rootDir,'results','behavior','full','evs_and_tis');
load(fpath)

ev_len = cellfun(@(x) size(x,2),evs);

%% load tracking data
fpath = fullfile(p.rootDir,'results','behavior','full','bvs.mat');
load(fpath)

% downsample from 20 to 5 Hz
% thrid argument in downsample necessary to get right number of frames
% (equivalent to floor() used in vid downsampling)
bvs = cellfun(@(x) downsample(x',4,mod(length(x),4))',bvs,'UniformOutput',false);
bv_len = cellfun(@(x) size(x,2),bvs);


%% load miniscope data
fpath = fullfile(p.rootDir,'results','traces.mat');
load(fpath)

[ traces ] = fix_traces_2daa( traces );
tr_len = cellfun(@(x) size(x,2),traces);

%% find correct correspondance between all signals

% cut off 2 values to match signals. it's not clear where they should
% be cut. 2 possible reasons for mismatch: onset latency / mismatch of
% miniscope internal 20 Hz clock and nidaq clock. 

% looking at the traces for shock trials suggests that it's a clock
% problem (later shocks are shifted wrt to nidaq signal)
% check_alignment_traces_nidaq (done for AA data) 

% -> cut off evs at beginning and end
evs = cellfun(@(x) x(:,2:end-1),evs,'UniformOutput',false);
ev_len = cellfun(@(x) size(x,2),evs);
% adjust tis accordingly
for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        % subtract 1 from trial start and trial stop entries
        tis{sub,ses}(1,:) = tis{sub,ses}(1,:) - 1;
        tis{sub,ses}(2,:) = tis{sub,ses}(2,:) - 1;
    end
end

% if there are further mismatches (here only by 1 time step), cut at
% the end. 
% this could be avoided by adjusting the preprocessing code 
% (floor in downsample movie)
for sub = 1:p.nSubjects
    for ses = 1:p.nSessions

        % evs
        mismatch = tr_len(sub,ses) - ev_len(sub,ses);
        if mismatch ~= 0
            disp(['Cutting evs by ' num2str(mismatch) ' for sub ' num2str(sub) ' ses ' num2str(ses)])  
            evs{sub,ses} = evs{sub,ses}(:,1:tr_len(sub,ses));
        end

        % bvs
        mismatch = tr_len(sub,ses) - bv_len(sub,ses);
        if mismatch ~= 0
            disp(['Cutting bvs by ' num2str(mismatch) ' for sub ' num2str(sub) ' ses ' num2str(ses)])  
            bvs{sub,ses} = bvs{sub,ses}(:,1:tr_len(sub,ses));
        end
    end
end

%% add info to tis
% starting position
% transition targer
% action start

% for converting quadrant index and trial type to transition type:
% trans_table(q_idx,trial_type) = trans_type
trans_table = [2 2 1 1;4 3 4 3]';

for sub = 1:size(tis,1)
    for ses = 1:size(tis,2)

        startingPos = zeros(1,size(tis{sub,ses},2));
        trans_target = zeros(1,size(tis{sub,ses},2));
        actionStart = zeros(1,size(tis{sub,ses},2));
        
        spd_diff = diff([bvs{sub,ses}(23,:) 0]);

        for tr = 1:size(tis{sub,ses},2) 
            % starting pos is the quadrant at the time of the trial start
            trialStart = tis{sub,ses}(1,tr);
            startingPos(tr) = bvs{sub,ses}(5,trialStart);

            % transition target is given by starting pos and trial type
            trial_type = tis{sub,ses}(4,tr)+1;
            trans_target(tr) = trans_table(startingPos(tr),trial_type);

            % ACTION START
            % only do this for AA sessions
            if tis{sub,ses}(5,tr) == 1 || tis{sub,ses}(5,tr) == 2
               if tis{sub,ses}(3,tr) == 0
                    tone_end = tis{sub,ses}(1,tr) + tis{sub,ses}(6,tr);
                    % action start alignment using speed
                    this_win = tone_end-10:tone_end;
                    [~,max_diff_idx] = max(spd_diff(this_win));
                    dt_start = 11-max_diff_idx;
                    rel_start = tis{sub,ses}(6,tr)-dt_start;
                    % in case actions start before tone start, set the
                    % action start to 1
                    if rel_start < 1
                        rel_start = 1;
                    end
                    actionStart(tr) = rel_start;
                end
            end
        end
        tis{sub,ses}(10,:) = trans_target;
        tis{sub,ses}(11,:) = startingPos;
        tis{sub,ses}(12,:) = actionStart;
    end
end

%% check again
ev_len = cellfun(@(x) size(x,2),evs);
tr_len = cellfun(@(x) size(x,2),traces);
bv_len = cellfun(@(x) size(x,2),bvs);

assert(sum(sum(abs(ev_len - tr_len))) == 0) 
assert(sum(sum(abs(ev_len - bv_len))) == 0) 

%% save
fpath = fullfile(p.rootDir,'results','allData');
save(fpath,'traces','evs','tis','bvs')
