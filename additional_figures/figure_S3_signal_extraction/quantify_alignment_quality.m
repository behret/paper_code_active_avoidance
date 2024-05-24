% load aligned cell maps and quantify MSE 
clear
p = params_2DAA;

%% load maps

for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        thisSub = p.subjects(sub);
        fpath = fullfile(p.rootDir,'miniscope', ['subject' num2str(thisSub)],['session' num2str(ses)],'extracted','cellMap.mat');
        load(fpath)
        maps{sub,ses} = cellMap;
    end
end

%% load verified alignments

[ mapsAligned, tforms ] = alignCellMaps(p, maps );

%% calculate MSE between sessions

mses = [];
for sub = 1:p.nSubjects
    for ses1 = 1:p.nSessions
        for ses2 = 1:p.nSessions
            mses(ses1,ses2,sub) = mse(mapsAligned{sub,ses1},mapsAligned{sub,ses2});
        end
    end
end
    
%% save data 
fpath = fullfile(p.data_dir,'session_alignment_mses');
save(fpath,'mses')