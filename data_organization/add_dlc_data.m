function bvs = add_dlc_data(p,bvs)

    for sub = 1:p.nSubjects
        sub
        thisSub = p.subjects(sub);
        for ses = 1:p.nSessions
            % load csv file
            trackPath = fullfile(p.rootDir,'results','behavior','dlc_results',['subject' num2str(thisSub) '_session' num2str(ses) '.csv']);

            % structure:
            % x/y coordinates of 
            % - tailbase
            % - ear right
            % - ear left
            % - ms base
            % - ms top
            % - centroid (mean of ears and ms base)
            T = readtable(trackPath);  % skips the first three rows of data
            col_idx = [2 3 5 6 8 9 11 12 14 15];
            pos_mat = table2array(T(3:end,col_idx));
            pos_mat = cellfun(@(x) str2num(x),pos_mat)';
            pos_mat(11,:) = mean(pos_mat([3 5 7],:));
            pos_mat(12,:) = mean(pos_mat([4 6 8],:));

            spds = [];
            for i = 1:6
                x = pos_mat(i*2-1,:);
                y = pos_mat(i*2,:);
                v_x = gradient(x, 1/p.frameRateRaw);
                v_y = gradient(y, 1/p.frameRateRaw);
                spds(i,:) = sqrt(v_x.^2 + v_y.^2);
            end
            
            % exception for m10s9 (see fix m10_s9.m for explanation)
            if strcmp(p.experimentName,'2DAA')
                if thisSub == 10 && ses ==9
                    nFramesTarget = 47993;
                    nFramesBe = size(spds,2);
                    spds = spds(:,nFramesBe-nFramesTarget+1:end);
                    pos_mat = pos_mat(:,nFramesBe-nFramesTarget+1:end);
                end
            end
           
            if length(bvs{sub,ses}) == length(spds)
                bvs{sub,ses} = cat(1,bvs{sub,ses},pos_mat,spds);
            else
                disp(ses)
            end
        end
    end
end


