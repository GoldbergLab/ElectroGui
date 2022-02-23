function handles = egm_Batch_feedback_label(handles)
% ElectroGui macro
% Batch label feedback patterns found in a particular channel

fileRangeString = ['1:' num2str(handles.TotalFileNumber)];

answer = inputdlg( ...
    {'File range to label', ...
     'Feedback channel number', ...
     'Interpattern silence length threshold in seconds', ...
     'Number of pattern types expected'}, ...
     'AutoLabelling Macro', 1, ...
     {fileRangeString, ...
      '17', ...
      '0.125', ...
      '6', ...
      });
if isempty(answer)
    return
end

labellingFileNums = eval(answer{1});
feedbackChannelNumber = str2double(answer{2});
silenceThresholdSeconds = str2double(answer{3});
numGroups = str2double(answer{4});
ax = handles.axes_Sonogram;
xlim(ax)
ylim(ax)
txt = text(mean(xlim(ax)), mean(ylim(ax)),'Extracting patterns... Click to quit.','horizontalalignment','center','fontsize',14,'color','r','backgroundcolor','w', 'Parent', ax);
set(txt,'ButtonDownFcn','set(gco,''color'',''g''); drawnow;');

patterns = [];

maxPatternLength = 0;

% Loop over files and find feedback patterns in the specified feedback
% channel
for fileIdx = 1:length(labellingFileNums)
    count = fileIdx;
    fileNum = labellingFileNums(fileIdx);
    if sum(get(txt,'color')==[0 1 0])==3
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
    data = logical(data);
    if size(data, 1) > size(data, 2)
        data = data';
    end
    % Load audio
    [snd, ~, ~, ~, ~] = eg_runPlugin(handles.plugins.loaders, handles.sound_loader, fullfile(handles.path_name, handles.sound_files(fileNum).name), true);
    if size(snd, 1) > size(snd, 2)
        snd = snd';
    end
    
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
    patternStarts = [risingEdges(1), risingEdges(breakIdx+1)+1];
    patternEnds = [fallingEdges(breakIdx), fallingEdges(end)];
    
    nextPatternNum = length(patterns)+1;
    for newPatternNum = 1:length(patternStarts)
%         patterns(nextPatternNum).pattern = data(max(1, patternStarts(newPatternNum)-2000):min(patternEnds(newPatternNum)+2000, length(data)));
        patterns(nextPatternNum).pattern = data(patternStarts(newPatternNum):patternEnds(newPatternNum));
        patterns(nextPatternNum).fileNum = fileNum;
        patterns(nextPatternNum).start = patternStarts(newPatternNum);
        patterns(nextPatternNum).end = patternEnds(newPatternNum);
        patterns(nextPatternNum).samplingRate = fs;
        patterns(nextPatternNum).audio = snd(patternStarts(newPatternNum):patternEnds(newPatternNum));
        idx = getOverlappingSegments(handles.SegmentTimes{fileNum}, patternStarts(newPatternNum), patternEnds(newPatternNum));
        if ~isempty(handles.SegmentTimes{fileNum})
            patterns(nextPatternNum).segments = handles.SegmentTimes{fileNum}(idx, :);
        else
            patterns(nextPatternNum).segments = [];
        end
        if length(patterns(nextPatternNum).pattern) > maxPatternLength
            maxPatternLength = length(patterns(nextPatternNum).pattern);
        end
        nextPatternNum = nextPatternNum + 1;
    end
    
    set(txt,'string',['Extracted patterns from file ' num2str(fileNum) ' (' num2str(fileIdx) '/' num2str(length(labellingFileNums)) '). Click to quit.']);
    drawnow;
end

set(txt,'string','Choose labels for each pattern or pattern group...');

% Pad patterns so they're all the same length
for k = 1:length(patterns)
    patterns(k).paddedPattern = [patterns(k).pattern, zeros(1, maxPatternLength-length(patterns(k).pattern))]; 
end


allPatterns = vertcat(patterns.paddedPattern);
groupIdx = kmeans(allPatterns, numGroups, 'EmptyAction', 'drop', 'Replicates', 5);

groupList = unique(groupIdx);

patternGroups = cell(1, length(groupList)+1);
patternGroupMeans = {};
patternGroupConformity = {};
weirdoIdx = length(groupList)+1;
for g = 1:length(groupList)
    patternGroups{g} = patterns(groupIdx == groupList(g));
    
    % Find a mean pattern
    patternGroupMeans{g} = mean(vertcat(patternGroups{g}.paddedPattern));
    % Calculate how much each pattern in this group conforms to the mean
    conformity = arrayfun(@(p) sum(p.paddedPattern == patternGroupMeans{g}), patternGroups{g});
    % Find average and std conformity 
    meanConformity = mean(conformity);
    stdConformity = std(conformity);
    % Create mask identifying weirdos (> 1 std from mean)
    weirdoMask = (meanConformity - stdConformity < conformity) & (conformity < meanConformity + stdConformity);
    % Split off weirdos into their own group
    patternGroups{weirdoIdx} = [patternGroups{weirdoIdx}, patternGroups{g}(weirdoMask)];
    % Keep only normos in this group.
    patternGroups{g} = patternGroups{g}(~weirdoMask);
end

% Remove any empty groups
emptyGroupIdx = [];
for g = 1:length(patternGroups)
    if isempty(patternGroups{g})
        emptyGroupIdx(end+1) = g;
    end
end
patternGroups(emptyGroupIdx) = [];

for g = 1:length(patternGroups)
    patternGroups{g} = PatternID(patternGroups{g});
%     figure;
%     for k = 1:length(patternGroups{g})
%         hold on;
%         plot(patternGroups{g}(k).paddedPattern + k*1.5);
%     end
end

patterns = [patternGroups{:}];

labels = {};
numUnlabeled = 0;
deletedSyllables = 0;
for k = 1:length(patterns)
    if ~isempty(patterns(k).ID)
        fileNum = patterns(k).fileNum;
        start = patterns(k).start;
        stop = patterns(k).end;
        ID = patterns(k).ID;
        % Find nearby segments
        idx = getNearbySegments(handles.SegmentTimes{fileNum}, start, stop, (stop-start)/2, length(ID));
        % Label nearby segments
        for j = 1:length(ID)
            % Loop over individual characters in ID string
            character = ID(j);
            if j > length(idx)
                break;
            end
            % Assign each character in the ID string to an individaul
            % segment
            handles.SegmentTitles{fileNum}{idx(j)} = character;
        end
            
    else
        numUnlabeled = numUnlabeled + 1;
    end
end

uniqueLabels = unique(labels);
fprintf('\nFinished batch feedback labelling\n');
fprintf('Label counts:\n');
for k = 1:length(uniqueLabels)
    fprintf('\t%s: %d\n', uniqueLabels{k}, sum(strcmp(uniqueLabels{k}, labels)));
end
fprintf('# of feedback events unlabeled: %d\n', numUnlabeled);
fprintf('# of pre-existing syllables deleted to clear the way for feedback syllables: %d\n', deletedSyllables);

set(txt,'string','Done labelling feedback!');
delete(txt);
drawnow;

msgbox('Autolabelling complete!', 'Autolabelling complete!');
%msgbox(['Segmented ' num2str(count) ' files.'],'Segmentation complete')

function idx = getNearbySegments(segmentTimes, t0, t1, maxExcursion, nSegments)
% Find a specified number of syllables within the time limits that are
%   closest to the center of the time interval. Max excursion is how far
%   outside the time range it is permissible to look.
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
    idx = 1;
    return;
end
idx = find((segmentTimes(:, 1) <= t0) & (segmentTimes(:, 2) >= t0) | ...
           (segmentTimes(:, 1) <= t1) & (segmentTimes(:, 2) >= t1) | ...
           (segmentTimes(:, 1) >= t0) & (segmentTimes(:, 2) <= t1));
