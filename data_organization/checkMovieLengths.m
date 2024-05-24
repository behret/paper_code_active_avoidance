%%
fnames = dir(['G:\E7_2DAA\**/*behavior1.avi']);
fnames([27,30]) = []; % exclude incomplete sessions for m1 and m4


for i = 1:length(fnames)
   fpath = [fnames(i).folder '\' fnames(i).name]; 
   fileinfo = aviinfo(fpath);
   nFrames_b(i) = fileinfo.NumFrames; 
end



%% 
fnames = dir(['G:\E7_miniscope_concat\**/*.h5']);
for i = 1:length(fnames)
   fpath = [fnames(i).folder '\' fnames(i).name]; 
   fileinfo = h5info(fpath);
   nFrames_m(i) = fileinfo.Datasets.Dataspace.Size(3); 
end


%%

for sub = 1:p.nSubjects
    for ses = 1:p.nSessions
        fpath1 = [p.rootDir 'behavior\session' num2str(ses) '\subject' num2str(sub) '\behavior1.avi'];
        fpath2 = [p.rootDir 'behavior\session' num2str(ses) '\subject' num2str(sub) '\behavior2.avi'];

        fileinfo = aviinfo(fpath1);
        nFrames1 = fileinfo.NumFrames; 
        fileinfo = aviinfo(fpath2);
        nFrames2 = fileinfo.NumFrames; 
        assert(nFrames1 == nFrames2)

        movLengths(sub,ses) = nFrames1; 

    end
end