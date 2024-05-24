% quick look at the decay times of calcium transients


p = params_2DAA

for sub = 1:p.nSubjects
    thisSub = p.subjects(sub);
    fpath = ['G:\E7_2DAA\miniscope\subject' num2str(thisSub) '\jointExtraction\sorted\eventData.mat'];
    load(fpath,'eventTraces')

    all_ev_mat = [];
    for c = 1:100 % only take first 100 to take mostly good cells

        full_length = cellfun(@(x) length(x),eventTraces{c}) == 40;
        ev_mat = cat(1,eventTraces{c}{full_length});

        all_ev_mat = cat(1,all_ev_mat,mean(ev_mat));

    end

    mean_event = mean(all_ev_mat);
    amp = max(mean_event) - min(mean_event);
    decPoint = amp*1/2 + min(mean_event);
    figure 
    hold on
    plot(mean_event)
    plot([0 40],[decPoint decPoint],'-k')
    plot([24 24],[0 1],'-k')

end




%% plot some cells' mean event
figure
for c = 1:40%length(events)
    
    full_length = cellfun(@(x) length(x),eventTraces{c}) == 40;
    ev_mat = cat(1,eventTraces{c}{full_length});
    
    subplot(4,10,c)
    plot(mean(ev_mat))
    %ylim([0,1])          
end


