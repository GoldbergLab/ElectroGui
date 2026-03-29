function egm_Fix_chunked_timestamps(obj)
% ElectroGui macro
% Fix timestamps for files that were chunked from longer parent recordings.
% When a long recording is split into chunks, the preprocessing pipeline
% may store the parent file's start time in every chunk rather than each
% chunk's actual time. This macro detects groups of files that share the
% same timestamp and reconstructs per-chunk times by accumulating sample
% counts within each group.
%
% Assumes files within each group are already in the correct order in the
% dbase (i.e., chunk 1 comes before chunk 2, etc.).
arguments
    obj electro_gui
end

numFiles = electro_gui.getNumFiles(obj.dbase);
if numFiles == 0
    warndlg('No files loaded in dbase.');
    return;
end

fs = obj.dbase.Fs;
if fs == 0
    warndlg('Sample rate (Fs) is zero — load a file first.');
    return;
end

% Read current timestamps and file lengths
times = obj.dbase.Times;
fileLengths = zeros(1, numFiles);
progressBar = waitbar(0, 'Reading file lengths...');
for k = 1:numFiles
    if ~isvalid(progressBar)
        return;
    end
    waitbar(k / numFiles, progressBar, sprintf('Reading file lengths (%d/%d)...', k, numFiles));
    fileLengths(k) = obj.getFileLength(k);
end

% Group consecutive files that share the same timestamp.
% A new group starts whenever the timestamp changes.
groupStarts = [1, find(diff(times) ~= 0) + 1];
groupEnds = [groupStarts(2:end) - 1, numFiles];
numGroups = length(groupStarts);

% Count how many files will be corrected (groups with >1 file)
numCorrected = 0;
for g = 1:numGroups
    groupSize = groupEnds(g) - groupStarts(g) + 1;
    if groupSize > 1
        numCorrected = numCorrected + groupSize - 1;
    end
end

if numCorrected == 0
    delete(progressBar);
    msgbox('All files already have unique timestamps — nothing to fix.');
    return;
end

% Reconstruct timestamps within each group
waitbar(0, progressBar, 'Fixing timestamps...');
for g = 1:numGroups
    if ~isvalid(progressBar)
        return;
    end
    waitbar(g / numGroups, progressBar, sprintf('Fixing group %d/%d...', g, numGroups));

    gStart = groupStarts(g);
    gEnd = groupEnds(g);
    if gStart == gEnd
        % Single-file group, nothing to fix
        continue;
    end

    % The first file in the group keeps its original timestamp.
    % Each subsequent file's timestamp is offset by the cumulative
    % duration of all preceding files in the group.
    baseTime = times(gStart);
    cumulativeSamples = 0;
    for k = gStart:gEnd
        offsetDays = cumulativeSamples / (fs * 86400);
        obj.dbase.Times(k) = baseTime + offsetDays;
        cumulativeSamples = cumulativeSamples + fileLengths(k);
    end
end

delete(progressBar);
msgbox(sprintf('Fixed timestamps for %d files across %d groups.', ...
    numCorrected, sum(groupEnds - groupStarts > 0)));
end
