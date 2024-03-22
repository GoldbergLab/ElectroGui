function dbase = getDbaseSummaryStats(dbase)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getDbaseSummaryStats: Output summary stats about an electro_gui dbase
% usage:  dbase = getDbaseSummaryStats(dbase, fileIdx)
%
% where,
%    dbase is a dbase struct generated by electro_gui, or the path to one
%
% electro_gui produces a dbase struct that contains a variety of data about
%   an array of data files. This function output some basic summary
%   statistics about the data in the dbase.
%
% See also: electro_gui
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If user provides a path, use it to load the dbase
if ischar(dbase)
    s = load(dbase, 'dbase');
    dbase = s.dbase;
end

uniqueFileLengths = unique(dbase.FileLength);
if length(uniqueFileLengths) == 1
    fileLength = sprintf('% 6.01f', uniqueFileLengths/dbase.Fs);
else
    meanLength = mean(dbase.FileLength)/dbase.Fs;
    stdLength = std(dbase.FileLength)/dbase.Fs;
    fileLength = sprintf('%.01f ± %.01f', meanLength, stdLength);
end

fprintf('\n************************* dbase summary *************************\n\n');
fprintf('Root path:                 %s\n', dbase.PathName);
fprintf('# of files:                %d\n', length(dbase.SoundFiles));
fprintf('# of non-sound channels:   %d\n', length(dbase.ChannelFiles));
fprintf('File length:               %s s\n', fileLength);
fprintf('Sampling rate:             %d Hz\n', dbase.Fs);

fprintf('\nSegments:\n')

numSegments = sum(cellfun(@length, dbase.SegmentTitles));
meanSegments = mean(cellfun(@length, dbase.SegmentTitles));
stdSegments = std(cellfun(@length, dbase.SegmentTitles));

durations = [];
for k = 1:length(dbase.SoundFiles)
    if ~isempty(dbase.SegmentTimes{k})
        durations = [durations, (dbase.SegmentTimes{k}(:, 2) - dbase.SegmentTimes{k}(:, 1))'];
    end
end

durations = 1000 * durations / dbase.Fs;
meanDuration = mean(durations);
stdDuration = std(durations);
pctFilesWithSegments = sum(cellfun(@(c)~isempty(c), dbase.SegmentTitles));

fprintf('   # of segments:          %d\n', numSegments);
fprintf('   # of segments/file:     %0.02f ± %0.02f\n', meanSegments, stdSegments);
fprintf('   Segment durations:      %0.01f ± %0.01f ms\n', meanDuration, stdDuration);
fprintf('   %% of files w/ segments: %0.01f%%\n', pctFilesWithSegments)
fprintf('\n')

titles = dbase.SegmentTitles(cellfun(@iscell, dbase.SegmentTitles));
titles = [titles{:}];
emptyTitleMask = cellfun(@(x)~ischar(x), titles);
titles(emptyTitleMask) = repmat({' '}, [1, sum(emptyTitleMask)]);
%titles = titles(cellfun(@ischar, titles));
uniqueTitles = unique(titles);
uniqueTitles = sort([uniqueTitles{:}]);

fprintf('   Segmment titles:    %s\n', uniqueTitles);

fprintf('   Title  Count   Duration\n');

for k = 1:length(uniqueTitles)
t = uniqueTitles(k);

numSegments = sum(strcmp(titles, t));

durations = [];
for j = 1:length(dbase.SoundFiles)
    if ~isempty(dbase.SegmentTimes{j})
        idx = strcmp(dbase.SegmentTitles{j}, t);
        durations = [durations, (dbase.SegmentTimes{j}(idx, 2) - dbase.SegmentTimes{j}(idx, 1))'];
    end
end

durations = 1000 * durations / dbase.Fs;
meanDuration = mean(durations);
stdDuration = std(durations);

if strcmp(t, ' ')
    displayTitle = '<none>';
else
    displayTitle = t;
end

fprintf('   %s\t\t%3d    % 6.01f ±%- 5.01f\n', displayTitle, numSegments, meanDuration, stdDuration);

end

fprintf('\nMarkers:\n');

if isfield(dbase, 'MarkerTitles')

numMarkers = sum(cellfun(@length, dbase.MarkerTitles));
meanMarkers = mean(cellfun(@length, dbase.MarkerTitles));
stdMarkers = std(cellfun(@length, dbase.MarkerTitles));

durations = [];
for k = 1:length(dbase.SoundFiles)
    if ~isempty(dbase.MarkerTimes{k})
        durations = [durations, (dbase.MarkerTimes{k}(:, 2) - dbase.MarkerTimes{k}(:, 1))'];
    end
end

durations = 1000 * durations / dbase.Fs;
meanDuration = mean(durations);
stdDuration = std(durations);
pctFilesWithMarkers = sum(cellfun(@(c)~isempty(c), dbase.MarkerTitles));

fprintf('   # of markers:          %d\n', numMarkers);
fprintf('   # of markers/file:     %0.02f ± %0.02f\n', meanMarkers, stdMarkers);
fprintf('   Marker durations:      %0.01f ± %0.01f ms\n', meanDuration, stdDuration);
fprintf('   %% of files w/ markers: %0.01f%%\n', pctFilesWithMarkers)
fprintf('\n')

titles = dbase.MarkerTitles(cellfun(@iscell, dbase.MarkerTitles));
titles = [titles{:}];
emptyTitleMask = cellfun(@(x)~ischar(x), titles);
titles(emptyTitleMask) = repmat(' ', [1, sum(emptyTitleMask)]);
%titles = titles(cellfun(@ischar, titles));
uniqueTitles = unique(titles);
uniqueTitles = sort([uniqueTitles{:}]);

fprintf('   Segmment titles:    %s\n', uniqueTitles);

fprintf('   Title  Count   Duration\n');

for k = 1:length(uniqueTitles)
t = uniqueTitles(k);

numMarkers = sum(strcmp(titles, t));

durations = [];
for j = 1:length(dbase.SoundFiles)
    if ~isempty(dbase.MarkerTimes{j})
        idx = strcmp(dbase.MarkerTitles{j}, t);
        durations = [durations, (dbase.MarkerTimes{j}(idx, 2) - dbase.MarkerTimes{j}(idx, 1))'];
    end
end

durations = 1000 * durations / dbase.Fs;
meanDuration = mean(durations);
stdDuration = std(durations);

if strcmp(t, ' ')
    displayTitle = '<none>';
else
    displayTitle = t;
end

fprintf('   %s\t\t%3d    % 6.01f ±%- 5.01f\n', displayTitle, numMarkers, meanDuration, stdDuration);

end

else
fprintf('   Markers not included in dbase\n');
end

fprintf('\n************************* dbase summary *************************\n\n');