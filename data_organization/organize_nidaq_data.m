% data organization for E7 2DAA experiment
clear
p = params_2DAA;

%% load and structure nidaq data

sesTypes = [0 1 1 1 2 2 2 2 2 3 3];

for sub = 1:p.nSubjects
    sub
    thisSub = p.subjects(sub);
    for ses = 1:p.nSessions

        sesDir = fullfile(p.rootDir,'behavior',['session' num2str(ses)],['subject' num2str(thisSub)]);
        
        fpath_inputs = fullfile(sesDir,'input_data.mat');
        fpath_outputs = fullfile(sesDir,'output_data.mat');
        if exist(fpath_inputs)
            load(fpath_inputs)
            load(fpath_outputs)

            % concat nidaq data from these 3 sources:
            % digitalData
                    %   1: platform signal
                    %   2: tone unblock signal as output from nidaq 
                    %   3: trial type (0 is horizontal, 1 is vertical)
            % inputData       
                    %   1: shock right (read from arduino)
                    %   2: arduiono status (1 if trial was shut off by arduino)
                    %   3: shock left (read from arduino)
                    %   4: bcam trigger
            % shockData  
                    % when shock is sent to arduino

            % new data structure:
            % 1: trial (tone and shock)
            % 2: tone planned
            % 3: shock planned
            % 4: platform planned
            % 5: tone actual
            % 6: shock actual
            % 7: platform actual
            % 8: shutoff
            % 9: horz trials (tone and shock)
            % 10: vert trials (tone and shock)

            nidaqData = zeros(10,size(shockData,2),'logical');
            nidaqData(1,:) = digitalData(2,:) | shockData(1,:);
            nidaqData(2,:) = digitalData(2,:);
            nidaqData(3,:) = shockData(1,:);
            nidaqData(4,:) = digitalData(1,:);
            nidaqData(5,:) = digitalData(2,:) & ~inputData(2,:);       
            % only need one shock signal here since they are the same
            nidaqData(6,:) = inputData(3,:) - mean(inputData(3,:)) > 3.8; % convert analog TTL signal to digital
            nidaqData(7,:) = digitalData(1,:); % has to be modified later (using ti info, see belwo)
            nidaqData(8,:) = inputData(2,:);
            % get trial type specific trial signals 
            nidaqData(9,:) = nidaqData(1,:) & ~digitalData(3,:);
            nidaqData(10,:) = nidaqData(1,:) & digitalData(3,:);

            % downsample to 5 Hz
            nidaqData = downsample(nidaqData',200)';
            evs{sub,ses} = nidaqData;
            
            
            
            % build structure containing info on every trial

            % structure of tis:
            % 1: trial start (tone start)
            % 2: trial stop (shock stop planned)
            % 3: outcome (0 avoid, 1 escape, 2 fail)
            % 4: trial type (0 is horizontal, 1 is vertical)
            % 5: ses type
            % 6: shutoff time
            % 7: 
            % 8: ses number
            % 9:
            %10:
            %11: starting side (added in collect_all_data)
            
            % get trial starts from nidaqData
            trialStarts = find([0 diff(evs{sub,ses}(1,:)) == 1]);

            % get trial stops
            trialStops = find([0 diff(evs{sub,ses}(1,:)) == -1]);

            % get trial types
            trialTypes = evs{sub,ses}(10,trialStarts);

          
            tis{sub,ses} = zeros(11,length(trialTypes));
            shutoff = zeros(size(trialTypes));
            outcome = zeros(size(trialTypes));
            shocked = zeros(size(trialTypes));
            % for every trial, check if and when mouse achieved shutoff
            for tr = 1:length(trialTypes)
                % get shutoff time
                shutoffTime = find(evs{sub,ses}(8,trialStarts(tr):trialStops(tr)),1,'first');
                if isempty(shutoffTime)
                    shutoff(tr) = 0;
                else
                    shutoff(tr) = shutoffTime;
                end

                % get trial outcome 
                % no escape (no shutoff)
                if shutoff(tr) == 0
                    outcome(tr) = 2; 
                % escape (shutoff time after tone end)
                elseif shutoff(tr) > 51 % changed form 50 to 51, see comment below
                    outcome(tr) = 1; 
                % avoid (shutoff time before tone end)
                else
                    outcome(tr) = 0; 
                end
                
                shocked(tr) = any(evs{sub,ses}(6,trialStarts(tr):trialStops(tr)));

                if ~any(ses == [1 10 11]) && shocked(tr) ~= (outcome(tr) > 0)
                    disp('Mismatch detected')                 
                end
                
                % there's a border effect here: sometimes the outcome derived
                % from the shutoff time and the one derived from the shock dont
                % match due to signal inaccuracy
                
                % looking at the signals it seems a shutoff registered at 51
                % is still early enough to turn off the shock. 
                % -> determination of outcome is accordingly adjusted 
                if outcome(tr) == 0
                    evs{sub,ses}(7,trialStarts(tr):trialStarts(tr)+125) = 0;
                end
                
            end
            
            ses_type = ones(1,length(trialTypes))*sesTypes(ses);
            ses_number = ones(1,length(trialTypes))*ses;
            
            tis{sub,ses}(1,:) = trialStarts;       
            tis{sub,ses}(2,:) = trialStops;
            tis{sub,ses}(3,:) = outcome;
            tis{sub,ses}(4,:) = trialTypes;
            tis{sub,ses}(5,:) = ses_type;
            tis{sub,ses}(6,:) = shutoff;
            %tis{sub,ses}(7,:) = 
            tis{sub,ses}(8,:) = ses_number;
            %tis{sub,ses}(9,:) = 
            %tis{sub,ses}(10,:) = 
            %tis{sub,ses}(11,:) = 

            
        else
            evs{sub,ses} = zeros(5,12000)/0;
            tis{sub,ses} = zeros(5,50)/0;
        end
    end
end

%% save

fpath = fullfile(p.rootDir,'results','behavior','full','evs_and_tis');
save(fpath,'evs','tis')

