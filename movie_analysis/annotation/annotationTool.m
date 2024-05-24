function [valid] = annotationTool(p,sub)


    %% specify output file
    savePath = fullfile(p.rootDir,'miniscope',['subject' num2str(sub)],'jointExtraction','sorted','PCAICAsorted.mat');
    if exist(savePath)
        existing_annotation_warning
        return
    end
    
    %% get necessary data
    % get heuristic sorting if any
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(sub)],'jointExtraction','sorted','heuristic_sorting.mat');
    if exist(fpath)
        sData = load(fpath,'heuristic_sorting');
        sortIdx = sData.heuristic_sorting;
    else
        sortIdx = 1:p.PCAICA.nICs;
    end
    
    % load results from PCA ICA
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(sub)],'jointExtraction','extracted','resultsPCAICA.mat');
    fData = load(fpath,'filters');
    filters = fData.filters(:,:,sortIdx);
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(sub)],'jointExtraction','extracted','norm_traces.mat');
    tData = load(fpath,'traces');
    traces = tData.traces(sortIdx,:); 
    % load prepared event data
    fpath = fullfile(p.rootDir,'miniscope',['subject' num2str(sub)],'jointExtraction','sorted','eventData');
    eventData = load(fpath);
    events = eventData.events(sortIdx);
    snapshotCollections = eventData.snapshotCollections(sortIdx);
    eventMovies = eventData.eventMovies(sortIdx);
    eventTraces = eventData.eventTraces(sortIdx);
    cellOutlines = eventData.cellOutlines(sortIdx);
    neighborOutlines = eventData.neighborOutlines(sortIdx);

    %%
    % set params
    nCells=size(filters,3);
    currentIdx = 1;

    % preallocate output
    valid = -1*ones(nCells,1);



    %% exclude cells that are too small or have no events

    %tooSmall = areas <= p.annotation.areaThresh; include again later
    tooSmall = zeros(nCells,1);
    noEvents = cellfun(@(x) isempty(x),events);
    skipCell = noEvents | tooSmall;

    %% Go through each cell

    h=figure('units','normalized','outerposition',[0 0 1 1]);
    finished=0;
    lastDir=1;
    i = 0;
    startFlag = 1;

    while ~finished   

        % set indices
        if i ~= currentIdx
            i = currentIdx;
            eventIdx = 1;    
        else
            eventIdx = eventIdx+1;
            if eventIdx > length(events{i})
                eventIdx = 1;
            end
        end

        if ~skipCell(i)

    %% plot data

            %plot filter
            figure(h)
            subplot(2,4,1);
            imagesc(filters(:,:,i));
            xlim([1,size(filters,2)])
            ylim([1,size(filters,1)])
            axis off
            title('Spatial Filter')

            % plot average transient
            subplot(2,4,2); 
            hold on
            % get cutouts around events
            transMat = [];
            for e = 1:length(events{i})
                if events{i}(e)>20 && events{i}(e) < size(traces,2)-30
                    thisTrans = traces(i,events{i}(e)-20:events{i}(e)+30);
                    transMat = cat(1,transMat,thisTrans);
                end
            end
            if ~isempty(transMat)
                plot(-20:1:30,transMat','k')
                plot(-20:1:30,nanmean(transMat,1),'r','LineWidth',2)
                set(gca,'xlim',[-20 30],'ylim',[min(transMat(:)) max(transMat(:))],'ytick',[])
                set(gca,'XTick',[-20,30])
                set(gca,'XTickLabel',[0 50]/p.frameRate)
                xlabel('Time (s)')
            end
            clear e transMat
            title('Mean Transient')


            % Plot whole trace
            subplot(2,4,[5 6]); 
            plot(traces(i,:),'k')
            if ~isempty(events{i})
                hold on
                plot(events{i},traces(i,events{i}),'r*');
                hold off
            end
            set(gca,'ylim',[min(traces(i,:)) max(traces(i,:))])
            set(gca,'YTick',[])
            title('Full Activity Trace')
            set(gca,'XTick',[0,size(traces,2)])
            display_len = round(size(traces,2)/(p.frameRate*60));
            frame_lim = display_len * (p.frameRate*60);
            set(gca,'XTickLabel',[0 display_len])
            xlim([0 frame_lim])
            xlabel('Time (min)')

            % plot event montage
            subplot(2,4,[3 4 7 8])
            imagesc(snapshotCollections{i})
            title(['Snapshots of ' num2str(length(events{i})) ' events'])
            axis off

            suptitle(sprintf('Candidate %d of %d, press h for instructions', currentIdx-sum(skipCell(1:currentIdx)), sum(~skipCell)))

    %% define button actions
            if startFlag
                showInstructions
                startFlag = 0;
            end
            figure(h);
            set(h, 'CurrentCharacter', 'k');
            waitforbuttonpress();
            reply=get(h, 'CurrentCharacter');

            if strcmpi(reply,'m') % event movie
                %playEventMovie(movie, i, traces(i,:), events{i}(eventOrder(eventIdx)), centroids, outlines, skipCell)
                playMovieCutout(eventMovies{i}{eventIdx}, eventTraces{i}{eventIdx}, cellOutlines{i}, neighborOutlines{i} )
            elseif strcmpi(reply,'y')   % valid 
                valid(i) = 1;
                currentIdx=currentIdx+1;
                lastDir=1;
            elseif strcmpi(reply,'n')   % invalid
                valid(i) = 0;  
                currentIdx=currentIdx+1;
                lastDir=1;
            elseif strcmpi(reply, 'c')  % contaminated 
                valid(i)=3; 
                currentIdx=currentIdx+1;
                lastDir=1;
            elseif strcmpi(reply, 'f')  % forward
                currentIdx=currentIdx+1; 
                lastDir=1;
            elseif strcmpi(reply, 'b')  % backwardh
                currentIdx=currentIdx-1;
                lastDir=-1;
            elseif strcmpi(reply,'q')   % quit
                finished=1;
            elseif strcmpi(reply,'h')   % display instructions
                showInstructions
            end

        else
            valid(i)=0;
            currentIdx=currentIdx+lastDir;
        end

        % when reaching end, show finishing dialog, if cells were skipped go back to 1
        if currentIdx>nCells
            currentIdx=1;
            if sum(valid == -1) == 0
                finishingDialog(savePath,valid)
                finished = 1;
            end
        elseif currentIdx<1
            currentIdx=nCells;
        end
    end

    close(h)
    

function showInstructions
    d = dialog('Position',[600 300 800 400],'Name','Instructions');
    
    txt = uicontrol('Parent',d,...
               'Style','text',...
               'FontSize',14,...
               'Position',[100 100 200 200],...
               'String',{'Annotation Keys','','y = yes','n = no', 'c = maybe'});

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'FontSize',14,...
               'Position',[500 100 200 200],...
               'String',{'Navigation Keys','','f = forward','b = back','m = show event movie','q = quit'});
                
    btn = uicontrol('Parent',d,...
               'KeyPressFcn','delete(gcf)',...
               'FontSize',14,...
               'Position',[300 50 200 70],...
               'String','Resume',...
               'Callback','delete(gcf)');

           
function finished = finishingDialog(savePath,valid)
    save(savePath,'valid')
    d = dialog('Position',[300 300 400 200],'Name','The End');
    finished = 0;
    txt = uicontrol('Parent',d,...
               'Style','text',...
               'FontSize',14,...
               'Position',[50 50 300 100],...
               'String','You are done!');
    btn = uicontrol('Parent',d,...
               'Position',[150 20 100 20],...
               'String','Ok',...
               'Callback','delete(gcf)');
           
           
function existing_annotation_warning
    d = dialog('Position',[300 300 400 200],'Name','Warning');
    finished = 0;
    txt = uicontrol('Parent',d,...
               'Style','text',...
               'FontSize',14,...
               'Position',[50 50 300 100],...
               'String','Warning: Existing annotation found - please delete or change filename and restart!');
    btn = uicontrol('Parent',d,...
               'Position',[150 20 100 20],...
               'String','Ok',...
               'Callback','delete(gcf)');
    