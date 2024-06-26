function [signalPeaksArray] = getPeaks( p,signalMatrix )
    % This might not be entirely accurate, since how many and which peaks
    % are found is dependent on the minTimeBtEvents paramter
    warning('off','signal:findpeaks:largeMinPeakHeight')

    for i=1:size(signalMatrix,1)
        inputSignal = signalMatrix(i,:);
        % get standard deviation of current signal
        inputSignalStd = nanstd(inputSignal(:));
        thisStdThreshold = inputSignalStd*p.annotation.numStdsForThresh;
        % run findpeaks, returns maxima above thisStdThreshold and ignores 
        % smaller peaks around larger maxima within minTimeBtEvents
        [~,testpeaks] = findpeaks(inputSignal,'minpeakheight',thisStdThreshold,'minpeakdistance',p.annotation.minTimeBtwEvents);
        
        signalPeaksArray{i} = testpeaks;
    end
end