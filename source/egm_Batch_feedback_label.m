function handles = egm_Batch_feedback_label(handles)
% ElectroGui macro
% Batch label feedback patterns found in a particular channel

fileRangeString = ['1:' num2str(handles.TotalFileNumber)];

answer = inputdlg( ...
    {'File range to label', ...
     'File range to search', ...
     'Feedback channel number', ...
     'Interpattern silence length threshold in seconds', ...
     'Max allowed BOS fractional duration variation', ...
     'BOS padding length in seconds'}, ...
     'AutoLabelling Macro', 1, ...
     {fileRangeString, ...
      fileRangeString, ...
      '17', ...
      '0.25', ...
      '0.05', ...
      '0.5', ...
      });
if isempty(answer)
    return
end

labellingFileNums = eval(answer{1});
searchFileNums = eval(answer{2});
feedbackChannelNumber = str2double(answer{3});
silenceThresholdSeconds = str2double(answer{4});
durationVariationThreshold = abs(str2double(answer{5}));
padLengthSeconds = str2double(answer{6});
ax = handles.axes_Sonogram;
xlim(ax)
ylim(ax)
txt = text(mean(xlim(ax)), mean(ylim(ax)),'Extracting patterns... Click to quit.','horizontalalignment','center','fontsize',14,'color','r','backgroundcolor','w', 'Parent', ax);
set(txt,'ButtonDownFcn','set(gco,''color'',''g''); drawnow;');

patterns = [];
templates = [];

maxPatternLength = 0;

% Loop over files and find feedback patterns in the specified feedback
% channel
for fileIdx = 1:length(searchFileNums)
    count = fileIdx;
    fileNum = searchFileNums(fileIdx);
    if all(get(txt,'color')==[0 1 0])
        count = count-1;
        delete(txt);
        msgbox('Labelling cancelled');
        return;
    end

    % Get all segment titles and times
    syllableTitles = handles.SegmentTitles{fileNum};
    numSegments = size(syllableTitles, 2);

    % Load channel data
    [data, fs, ~, ~, ~] = eg_runPlugin(handles.plugins.loaders, handles.chan_loader{feedbackChannelNumber}, fullfile(handles.path_name, handles.chan_files{feedbackChannelNumber}(fileNum).name), true);
    data = data > 0.5;
    if size(data, 1) > size(data, 2)
        data = data';
    end
    % Load audio
    [snd, ~, ~, ~, ~] = eg_runPlugin(handles.plugins.loaders, handles.sound_loader, fullfile(handles.path_name, handles.sound_files(fileNum).name), true);
    if size(snd, 1) > size(snd, 2)
        snd = snd';
    end
    
    % Convert pathLength from seconds to samples
    padLength = round(padLengthSeconds * fs);
    
    % Convert silence threshold from seconds to samples
    silenceThreshold = silenceThresholdSeconds * fs;

    % Find pulse edges
    ddata = diff(data);
    risingEdges = find(ddata == 1);
    fallingEdges = find(ddata == -1);

    if isempty(fallingEdges) || isempty(risingEdges)
        % No pulses - skip this file
        continue;
    end
    
    % Trim edges to make sure we aren't starting or ending on a high level
    if fallingEdges(1) < risingEdges(1)
        % File must start high - delete first falling edge
        fallingEdges(1) = [];
    end
    if risingEdges(end) > fallingEdges(end)
        % File must end high - delete last rising edge
        risingEdges(end) = [];
    end
    
    interPulseIntervals = risingEdges(2:end) - fallingEdges(1:end-1);
    breakIdx = find(interPulseIntervals > silenceThreshold);
    patternStarts = [risingEdges(1), risingEdges(breakIdx+1)+1] - padLength;
    patternEnds = [fallingEdges(breakIdx), fallingEdges(end)] + padLength;
    
    % Ensure the pad doesn't cause patterns to extend past the ends of the
    % file
    patternStarts(patternStarts < 1) = 1;
    patternEnds(patternEnds > length(data)) = length(data);
    
    
    % Loop over patterns found and assemble data into struct array
    for newPatternNum = 1:length(patternStarts)
        newPattern.pattern = data(patternStarts(newPatternNum):patternEnds(newPatternNum));
        newPattern.fileNum = fileNum;
        newPattern.start = patternStarts(newPatternNum);
        newPattern.end = patternEnds(newPatternNum);
        newPattern.duration = patternEnds(newPatternNum) - patternStarts(newPatternNum);
        newPattern.samplingRate = fs;
        newPattern.audio = snd(patternStarts(newPatternNum):patternEnds(newPatternNum));
        idx = getOverlappingSegments(handles.SegmentTimes{fileNum}, patternStarts(newPatternNum), patternEnds(newPatternNum));
        if ~isempty(handles.SegmentTimes{fileNum})
            newPattern.segmentTimes = handles.SegmentTimes{fileNum}(idx, :) - newPattern.start;
            newPattern.titles = handles.SegmentTitles{fileNum}(idx);
            % Check if this pattern is labeled or not. If it's labeled, add
            % it to the templates array. If it is unlabeled, add it to the
            % pattern array.
            patternIsLabeled = false;
            for segmentNum = 1:length(newPattern.titles)
                if ~isempty(newPattern.titles{segmentNum})
                    patternIsLabeled = true;
                    break;
                end
            end
            if patternIsLabeled
                if isempty(templates)
                    templates = newPattern;
                else
                    templates(end+1) = newPattern;
                end
            else
                if isempty(patterns)
                    patterns = newPattern;
                else
                    patterns(end+1) = newPattern;
                end
            end
        else
            % No segments found
            newPattern.segmentTimes = [];
            newPattern.titles = {};
            patterns(end+1) = newPattern;
        end
        if length(patterns(end).pattern) > maxPatternLength
            maxPatternLength = length(patterns(end).pattern);
        end
    end
    
    set(txt,'string',fprintf('Extracted patterns from file %d (%d / %d). Click to quit.\n', fileNum, fileIdx, length(labellingFileNums)));
    drawnow;
end

if isempty(templates)
    error('No templates found. Please make sure you label at least one feedback event!');
end

% Find max and min allowable durations and weed out obviously unusable
% patterns
maxDuration = max([templates.duration]) * (1+durationVariationThreshold);
minDuration = min([templates.duration]) * (1-durationVariationThreshold);
patterns([patterns.duration] > maxDuration) = [];
patterns([patterns.duration] < minDuration) = [];

% Pad patterns so they're all the same length
for k = 1:length(patterns)
    patterns(k).paddedPattern = [patterns(k).pattern, zeros(1, maxPatternLength-length(patterns(k).pattern))]; 
end

% Pad templates so they're all the same length
for k = 1:length(templates)
    templates(k).paddedPattern = [templates(k).pattern, zeros(1, maxPatternLength-length(templates(k).pattern))]; 
end

maxLag = max(100, padLength);
similarity = zeros(length(templates), length(patterns));
% Get similarity score for each pattern with each template
for k = 1:length(templates)
    % Normalize template pattern so they can be compared to each other
    templatePaddedPattern = templates(k).paddedPattern;
    templatePaddedPattern = templatePaddedPattern;
    for j = 1:length(patterns)
        similarity(k, j) = max(xcorr(templatePaddedPattern, patterns(j).paddedPattern, maxLag));
        patterns(j).similarity = similarity(:, j);
    end
end

% Assign each pattern to one template or the other
[~, assignments] = max(similarity, [], 1);
for k = 1:length(templates)
    templates(k).assignedPatterns = patterns(assignments == k);
end

for k = 1:length(templates)
    figure;
    ax = axes();
    hold(ax, 'on');
    for j = 1:length(templates(k).assignedPatterns)
        plot(ax, templates(k).assignedPatterns(j).paddedPattern + (j-1) * 1.1);
    end
end

labels = {};
numUnlabeled = 0;
for k = 1:length(templates)
    newTitles = templates(k).titles;
    newSelection = true(1, length(newTitles));
    for j = 1:length(templates(k).assignedPatterns)
        pattern = templates(k).assignedPatterns(j);
        fileNum = pattern.fileNum;
        start = pattern.start;
        stop = pattern.end;
        % Find nearby segments
        idx = getNearbySegments(handles.SegmentTimes{fileNum}, start, stop, padLength);
        % Delete nearby segments
        handles.SegmentTimes{fileNum}(idx, :) = [];
        handles.SegmentTitles{fileNum}(idx) = [];
        handles.SegmentSelection{fileNum}(idx) = [];
        % Add in new segments from template
        startIdx = min(idx);
        newTimes = templates(k).segmentTimes + pattern.start;
        handles.SegmentTimes{fileNum} = [handles.SegmentTimes{fileNum}(1:(startIdx-1), :); newTimes; handles.SegmentTimes{fileNum}(startIdx:end, :)];
        handles.SegmentTitles{fileNum} = [handles.SegmentTitles{fileNum}(1:(startIdx-1)), newTitles, handles.SegmentTitles{fileNum}(startIdx:end)];
        handles.SegmentSelection{fileNum} = [handles.SegmentSelection{fileNum}(1:(startIdx-1)), newSelection, handles.SegmentSelection{fileNum}(startIdx:end)];
    end
end

% uniqueLabels = unique(labels);
% fprintf('\nFinished batch feedback labelling\n');
% fprintf('Label counts:\n');
% for k = 1:length(uniqueLabels)
%     fprintf('\t%s: %d\n', uniqueLabels{k}, sum(strcmp(uniqueLabels{k}, labels)));
% end
% fprintf('# of feedback events unlabeled: %d\n', numUnlabeled);

set(txt,'string','Done labelling feedback!');
delete(txt);
drawnow;

msgbox('Autolabelling complete!', 'Autolabelling complete!');
%msgbox(['Segmented ' num2str(count) ' files.'],'Segmentation complete')

function idx = getNearbySegments(segmentTimes, t0, t1, maxExcursion, nSegments)
% Find a specified number of syllables within the time limits that are
%   closest to the center of the time interval. Max excursion is how far
%   outside the time range it is permissible to look.
if ~exist('nSegments', 'var') || isempty(nSegments)
    nSegments = Inf;
end
idx = getOverlappingSegments(segmentTimes, t0-maxExcursion, t1+maxExcursion);
if length(idx) <= nSegments
    % There are just enough segments, or not enough - no need to winnow
    % them down.
    return;
end
% Get array of center times for nearby segments
centerTimes = mean(segmentTimes(idx, :), 2);
% Get sort indices for nearby segments by distance from center time to
% middle of interval
[~, closestIdx] = sort(abs(centerTimes - mean([t0, t1])));
% Arrange segment indices accoring to distance from middle of interval
idx = idx(closestIdx);
% Find the closest N
idx = sort(idx(1:nSegments));

function idx = getOverlappingSegments(segmentTimes, t0, t1)
% Return list of indices of segments that overlap given time (in samples)
if isempty(segmentTimes)
    idx = [];
    return;
end
idx = find((segmentTimes(:, 1) <= t0) & (segmentTimes(:, 2) >= t0) | ...
           (segmentTimes(:, 1) <= t1) & (segmentTimes(:, 2) >= t1) | ...
           (segmentTimes(:, 1) >= t0) & (segmentTimes(:, 2) <= t1));
