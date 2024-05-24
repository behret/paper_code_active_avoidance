function [ cols,alpha ] = chooseColors( input_args )


% chose colors for different session types

% HAB
% FC
% EXT
% AA 
% AA vert

%%          
    alpha = .4;

    cols(1,:) = [1 1 1];  % white
    cols(2,:) = [1 .5 0];  % orange
    cols(3,:) = [0 .5 1];  % blue
    cols(4,:) = [.3 .8 .3];  % green
    cols(5,:) = [.7 .7 .7]; % gray


    %% 
    if 0
        figure
        subplot(1,3,1)
        alpha = .4;
        hold on
        area([.5 1.5],[1 1],'FaceColor',cols(1,:),'FaceAlpha',alpha,'LineStyle','none')
        area([1.5 2.5],[1 1],'FaceColor',cols(2,:),'FaceAlpha',alpha,'LineStyle','none')
        area([2.5 3.5],[1 1],'FaceColor',cols(5,:),'FaceAlpha',alpha,'LineStyle','none')
        xlim([.5 3.5])

        subplot(1,3,2)
        hold on
        area([.5 1.5],[1 1],'FaceColor',cols(1,:),'FaceAlpha',alpha,'LineStyle','none')
        area([1.5 2.5],[1 1],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none')
        area([2.5 3.5],[1 1],'FaceColor',cols(2,:),'FaceAlpha',alpha,'LineStyle','none')
        area([3.5 4.5],[1 1],'FaceColor',cols(5,:),'FaceAlpha',alpha,'LineStyle','none')
        xlim([.5 4.5])


        subplot(1,3,3)
        hold on
        area([.5 1.5],[1 1],'FaceColor',cols(1,:),'FaceAlpha',alpha,'LineStyle','none')
        area([1.5 2.5],[1 1],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none')
        area([2.5 3.5],[1 1],'FaceColor',cols(4,:),'FaceAlpha',alpha,'LineStyle','none')
        area([3.5 4.5],[1 1],'FaceColor',cols(5,:),'FaceAlpha',alpha,'LineStyle','none')
        xlim([.5 4.5])
        
        
        
        figure
        hold on
        area([.5 1.5],[1 1],'FaceColor',cols(1,:),'FaceAlpha',alpha,'LineStyle','none')
        area([1.5 2.5],[1 1],'FaceColor',cols(2,:),'FaceAlpha',alpha,'LineStyle','none')
        area([2.5 3.5],[1 1],'FaceColor',cols(3,:),'FaceAlpha',alpha,'LineStyle','none')
        area([3.5 4.5],[1 1],'FaceColor',cols(4,:),'FaceAlpha',alpha,'LineStyle','none')
        area([4.5 5.5],[1 1],'FaceColor',cols(5,:),'FaceAlpha',alpha,'LineStyle','none')
        xlim([.5 5.5])        
        
        
        [~,leg] = legend('Hab.','FC','AA','vAA','Ext.','Location','northeastoutside');
        PatchInLegend = findobj(leg, 'type', 'patch');
        set(PatchInLegend, 'FaceAlpha', alpha,'EdgeColor','k','LineStyle','-','EdgeAlpha',.8);

    end

end
