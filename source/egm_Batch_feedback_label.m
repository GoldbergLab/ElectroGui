function handles = egm_Batch_feedback_label(handles)
% ElectroGui macro
% Batch label feedback patterns found in a particular channel

fileRangeString = ['1:' num2str(handles.TotalFileNumber)];
currentFileNum = num2str(getCurrentFileNum(handles));

answer = inputdlg( ...
    {'File range to label', ...
     'File range to search', ...
     'Feedback channel number (channel containing feedback signal)', ...
     'Interpattern silence length threshold in seconds (how far between signal spikes for them to be considered separate patterns)', ...
     'Max allowed BOS fractional duration variation (0 = zero allowed variation, 1 = 100% allowed variation)', ...
     'BOS padding length in seconds (how far outside channel signal to look for syllables)'}, ...
     'AutoLabelling Macro', 1, ...
     {fileRangeString, ...
      currentFileNum, ...
      '17', ...
      '0.25', ...
      '0.05', ...
      '0.25', ...
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

searchAndLabelFileNums = sort(unique([labellingFileNums, searchFileNums]));

stats.nonSearchingLabeled = 0;
stats.nonLabelingUnlabeled = 0;
stats.patternOverlappingFileEnd = 0;

fileLengths = nan(1, max(searchAndLabelFileNums));

fileIdx = 0;
% Loop over files and find feedback patterns in the specified feedback
% channel
for fileNum = searchAndLabelFileNums
    fileIdx = fileIdx + 1;
    searchFile = any(fileNum == searchFileNums);
    labelFile = any(fileNum == labellingFileNums);
    if all(get(txt,'color')==[0 1 0])
        delete(txt);
        msgbox('Labelling cancelled');
        return;
    end

    % Load channel data
    [data, fs, ~, ~, ~] = eg_runPlugin(handles.plugins.loaders, handles.chan_loader{feedbackChannelNumber}, fullfile(handles.DefaultRootPath, handles.chan_files{feedbackChannelNumber}(fileNum).name), true);
    data = data > 0.5;
    if size(data, 1) > size(data, 2)
        data = data';
    end
    % Load audio
    [snd, ~, ~, ~, ~] = eg_runPlugin(handles.plugins.loaders, handles.sound_loader, fullfile(handles.DefaultRootPath, handles.sound_files(fileNum).name), true);
    if size(snd, 1) > size(snd, 2)
        snd = snd';
    end
    
    % Record file length
    fileLengths(fileNum) = length(snd);
    
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
    
    % Find pattern onsets and offsets
    interPulseIntervals = risingEdges(2:end) - fallingEdges(1:end-1);
    breakIdx = find(interPulseIntervals > silenceThreshold);
    patternStarts = [risingEdges(1), risingEdges(breakIdx+1)+1]; % - padLength;
    patternEnds = [fallingEdges(breakIdx), fallingEdges(end)]; % + padLength;
    
    % Ensure the pad doesn't cause patterns to extend past the ends of the
    % file
    patternStarts(patternStarts < 1) = 1;
    patternEnds(patternEnds > length(data)) = length(data);
    
    % Loop over patterns found and assemble data into struct array
    for newPatternNum = 1:length(patternStarts)
        % Create a new pattern object
        newPattern.pattern = data(patternStarts(newPatternNum):patternEnds(newPatternNum));
        newPattern.fileNum = fileNum;
        newPattern.start = patternStarts(newPatternNum);
        newPattern.end = patternEnds(newPatternNum);
        newPattern.duration = patternEnds(newPatternNum) - patternStarts(newPatternNum);
        newPattern.samplingRate = fs;
        newPattern.audio = snd(patternStarts(newPatternNum):patternEnds(newPatternNum));
%        idx = getOverlappingSegments(handles.SegmentTimes{fileNum}, patternStarts(newPatternNum), patternEnds(newPatternNum));
        idx = getNearbySegments(handles.SegmentTimes{fileNum}, patternStarts(newPatternNum), patternEnds(newPatternNum), padLength);
        
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
            if patternIsLabeled && searchFile
                % This is in a search file, and it is labeled - it's a
                % template!
                if isempty(templates)
                    templates = newPattern;
                else
                    templates(end+1) = newPattern;
                end
            elseif ~patternIsLabeled && labelFile
                % This is ia label file and it is unlabeled. Add it to the
                % list to be labeled!
                if isempty(patterns)
                    patterns = newPattern;
                else
                    patterns(end+1) = newPattern;
                end
            elseif patternIsLabeled && ~searchFile
                stats.nonSearchingLabeled = stats.nonSearchingLabeled + 1;
            elseif ~patternIsLabeled && ~labelFile
                stats.nonLabelingUnlabeled = stats.nonLabelingUnlabeled + 1;
            end
        else
            % No segments found
            newPattern.segmentTimes = [];
            newPattern.titles = {};
            patterns(end+1) = newPattern;
        end
        if ~isempty(patterns) && length(patterns(end).pattern) > maxPatternLength
            maxPatternLength = length(patterns(end).pattern);
        end
    end
    
    fprintf('Extracted patterns from file %d (%d / %d)...\n', fileNum, fileIdx, length(searchAndLabelFileNums));
    set(txt,'string',sprintf('Extracted patterns from file %d (%d / %d). Click to quit.\n', fileNum, fileIdx, length(searchAndLabelFileNums)));
    drawnow;
end

if isempty(templates)
    error('No templates found. Please make sure you label at least one feedback event!');
end

stats.numPatternsFound = length(patterns);
stats.numTemplatesFound = length(templates);
stats.numLabelFiles = length(labellingFileNums);
stats.numSearchFiles = length(searchFileNums);

% Find max and min allowable durations and weed out obviously unusable
% patterns
maxDuration = max([templates.duration]) * (1+durationVariationThreshold);
minDuration = min([templates.duration]) * (1-durationVariationThreshold);

tooLongPatternIdx = [patterns.duration] > maxDuration;
tooShortPatternIdx = [patterns.duration] < minDuration;

stats.numTooShortPatterns = sum(tooShortPatternIdx);
stats.numTooLongPatterns = sum(tooLongPatternIdx);

rejectedPatterns = patterns(tooLongPatternIdx | tooShortPatternIdx);
patterns(tooLongPatternIdx) = [];
patterns(tooShortPatternIdx) = [];

% Pad patterns so they're all the same length
for k = 1:length(patterns)
    patterns(k).paddedPattern = [patterns(k).pattern, zeros(1, maxPatternLength-length(patterns(k).pattern))]; 
end

% Pad templates so they're all the same length
for k = 1:length(templates)
    templates(k).paddedPattern = [templates(k).pattern, zeros(1, maxPatternLength-length(templates(k).pattern))]; 
end

% Pad rejected patterns so they're all the same length
for k = 1:length(rejectedPatterns)
    rejectedPatterns(k).paddedPattern = [rejectedPatterns(k).pattern, zeros(1, maxPatternLength-length(rejectedPatterns(k).pattern))]; 
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

stats.meanSimilarity = mean(similarity, 2);
stats.stdSimilarity = std(similarity, [], 2);
stats.maxSimilarity = max(similarity, [], 2);
stats.minSimilarity = min(similarity, [], 2);

% Assign each pattern to one template or the other
[~, assignments] = max(similarity, [], 1);
for k = 1:length(templates)
    templates(k).assignedPatterns = patterns(assignments == k);
end

% Plot matched patterns
for k = 1:length(templates)
    figure;
    ax = axes();
    title(sprintf('Template #%d/%d and matched patterns', k, length(templates)));
    hold(ax, 'on');
    plot(ax, templates(k).paddedPattern, 'r');
    for j = 1:length(templates(k).assignedPatterns)
        plot(ax, templates(k).assignedPatterns(j).paddedPattern + j * 1.1, 'b');
    end
end

% Plot rejected patterns
figure;
ax = axes();
title('Rejected patterns');
hold(ax, 'on');
for j = 1:length(rejectedPatterns)
    plot(ax, rejectedPatterns(j).paddedPattern + (j-1) * 1.1, 'b');
end

% Replace each pattern segmentation with appropriate template segmentation & labeling
for k = 1:length(templates)
    newTitles = templates(k).titles;
    newSelection = true(1, length(newTitles));
    for j = 1:length(templates(k).assignedPatterns)
        pattern = templates(k).assignedPatterns(j);
        fileNum = pattern.fileNum;
        % Construct new times
        newTimes = templates(k).segmentTimes + pattern.start;
        % Check if new times will go off ends of file or not
        if min(newTimes(:)) < 1 || max(newTimes(:)) > fileLengths(fileNum)
            % This pattern overlaps the beginning or end of the file.
            % Ignore it.
            stats.patternOverlappingFileEnd = stats.patternOverlappingFileEnd + 1;
            continue;
        end
        % Find nearby segments
        idx = getNearbySegments(handles.SegmentTimes{fileNum}, pattern.start, pattern.end, padLength);
        % Delete nearby segments
        handles.SegmentTimes{fileNum}(idx, :) = [];
        handles.SegmentTitles{fileNum}(idx) = [];
        handles.SegmentSelection{fileNum}(idx) = [];
        % Add in new segments from template
        startIdx = min(idx);
        handles.SegmentTimes{fileNum} = [handles.SegmentTimes{fileNum}(1:(startIdx-1), :); newTimes; handles.SegmentTimes{fileNum}(startIdx:end, :)];
        handles.SegmentTitles{fileNum} = [handles.SegmentTitles{fileNum}(1:(startIdx-1)), newTitles, handles.SegmentTitles{fileNum}(startIdx:end)];
        handles.SegmentSelection{fileNum} = [handles.SegmentSelection{fileNum}(1:(startIdx-1)), newSelection, handles.SegmentSelection{fileNum}(startIdx:end)];
    end
end

set(txt,'string','Done labelling feedback!');
delete(txt);
drawnow;

disp('Auto-labeling statistics:')
disp(stats)

msgbox('Autolabelling complete!', 'Autolabelling complete!');

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

function currentFileNum = getCurrentFileNum(handles)
currentFileNum = str2double(get(handles.edit_FileNumber, 'string'));