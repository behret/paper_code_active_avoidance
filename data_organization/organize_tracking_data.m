% organization of tracking data for E7 2DAA experiment
clear
p = params_2DAA;

for sub = 1:p.nSubjects
    sub
    for ses = 1:p.nSessions
        thisSub = p.subjects(sub);
        % load centroids
        trackPath = fullfile(p.rootDir,'results','behavior','tracks',['subject' num2str(thisSub)],['session' num2str(ses)],'centroids.mat');
        if exist(trackPath)
            load(trackPath)
            bvs{sub,ses} = processTracks(p,centroid);
            bvs{sub,ses} = addQuadrant(bvs{sub,ses});
        else
            bvs{sub,ses} = [];
        end
    end
end

bvs = add_dlc_data(p,bvs);

%% save
savePath = fullfile(p.rootDir,'results','behavior','full','bvs');
save(savePath,'bvs')

