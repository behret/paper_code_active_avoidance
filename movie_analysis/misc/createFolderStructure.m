function createFolderStructure(p)

    miniDir = fullfile(p.rootDir,'miniscope');
    mkdir(miniDir)
    currDir = pwd;
    cd(miniDir)

    for i = 1:length(p.subjects)
        dirName = ['subject' num2str(p.subjects(i))];
        mkdir(dirName)
        cd(dirName)
        for j = 1:p.nSessions
            dirName = ['session' num2str(j)];
            mkdir(dirName)
            cd(dirName)
            mkdir preprocessed
            mkdir extracted
            mkdir sorted
            cd ..
        end
        if p.nSessions > 1
            mkdir jointExtraction
            cd('jointExtraction')
            mkdir extracted
            mkdir sorted
            mkdir alignment
            cd .. 
        end
        cd ..
    end

    cd(currDir)

end

