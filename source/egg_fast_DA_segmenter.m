function segmentTimes = egg_fast_DA_segmenter(sound, amplitude, fs, threshold, params)
% ElectroGui segmenter - sped up by bmk27

defaultParams.Names = {'Minimum duration (ms)','Minimum interval (ms)','Mininum duration for splitting (ms)','Minimum interval for splitting (ms)'};
defaultParams.Values = {'7', '7','7','0'};

if ischar(sound) && strcmp(sound, 'params')
    segmentTimes = defaultParams;
    return
end

if ~exist('params', 'var')
    params = defaultParams;
end

min_dur = str2double(params.Values{1})/1000;
min_stop = str2double(params.Values{2})/1000;

if params.IsSplit == 1
    min_dur = str2double(params.Values{3})/1000;
    min_stop = str2double(params.Values{4})/1000;
end

if threshold < 0
    amplitude = -amplitude;
    threshold = -threshold;
end
threshold = threshold - min(amplitude);
amplitude = amplitude - min(amplitude);

% Find threshold crossing points
segmentTimes = [];
amplitude = [0; amplitude; 0];
segmentTimes(:,1) = find(amplitude(1:end-1)<threshold & amplitude(2:end)>=threshold)-1;
segmentTimes(:,2) = find(amplitude(1:end-1)>=threshold & amplitude(2:end)<threshold)-1;
amplitude = amplitude(2:end-1);

% Eliminate VERY short syllables
longEnoughIdx = segmentTimes(:, 2) - segmentTimes(:, 1) > min_dur*fs/2;
segmentTimes = segmentTimes(longEnoughIdx,:);

% Extend syllables to a lower threshold
if params.IsSplit == 0
    warning off
    mn = mean(amplitude(amplitude<threshold));
    st = std(amplitude(amplitude<threshold));
    warning on
    newThreshold = min([threshold mn+2*st]);
    for segmentNum = 1:size(segmentTimes,1)
        if segmentNum > 1
            startSearch = segmentTimes(segmentNum - 1, 2) - 1;
        else
            startSearch = 1;
        end
        endSearch = segmentTimes(segmentNum,1)-1;

        segmentTimes(segmentNum, 1) = max([1; find(amplitude(startSearch:endSearch) < newThreshold, 1, 'last') + startSearch - 1]);
       
        startSearch = segmentTimes(segmentNum,2)+1;
        if segmentNum < size(segmentTimes, 1)
            endSearch = segmentTimes(segmentNum + 1, 1) + 1;
        else
            endSearch = length(amplitude);
        end
        segmentTimes(segmentNum, 2) = min([length(amplitude); find(amplitude(startSearch:endSearch) < threshold/2, 1, 'first') + startSearch - 1]);
    end
end

% Eliminate short syllables
longEnoughIdx = diff(segmentTimes, 1, 2) > min_dur*fs;
segmentTimes = segmentTimes(longEnoughIdx,:);

if isempty(segmentTimes)
    segmentTimes = zeros(0,2);
    return
end

% Eliminate short intervals
if size(segmentTimes,1)>1
    longEnoughIdx = [find(segmentTimes(2:end,1)-segmentTimes(1:end-1,2) > min_stop*fs); length(segmentTimes)];
    segmentTimes = [segmentTimes([1; longEnoughIdx(1:end-1)+1],1), segmentTimes(longEnoughIdx,2)];
end