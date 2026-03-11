function obj = egm_WarbleScan(obj)
% ElectroGui macro
% Scan through pre-segmented files and mark files if they likely contain
%   significant amounts of warble
arguments
    obj electro_gui
end

% Get some user input for macro
fileRangeString = ['1:' num2str(electro_gui.getNumFiles(obj.dbase))];
answer = inputdlg( ...
    {'File range to scan', ...
     'Warble must-have segments (comma separated)', ...
     'Minimum segment time percentage', ...
     'Property name to mark'}, ...
     'Macro name', 1, ...
     {fileRangeString, ...
     'h, b, e, x', ...
     '20', ...
      'bGood'});

if isempty(answer)
    % User cancelled
    return
end

filenums = eval(answer{1});
warbleSegments = cellfun(@(s)strip(s), split(answer{2}, ','))';
minTimePercentage = eval(answer{3});
propertyName = answer{4};

% Check if property already exists in dbase
if ~obj.isProperty(propertyName)
    % It does not exist, add it
    obj.addProperty(propertyName, false);
end

% Loop over selected files and do something
progressBar = ProgressBar('Scanning for warble...', "WindowStyle", "modal");

goodWarbleCount = 0;

for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    if ~isvalid(progressBar)
        % User x-ed out progress bar, terminate
        warndlg('Macro terminated by user at %dth file of %d', (fileIdx+1), length(filenums));
        break;
    end

    % Update progress bar
    progressBar.Progress = fileIdx / length(filenums);

    % Initialize good warble variable
    isGoodWarble = false;

    % Check for at least one required segment
    hasAtLeastOneRequiredSegment = false;
    for k = 1:length(obj.dbase.SegmentTitles{filenum})
        segTitle = obj.dbase.SegmentTitles{filenum}{k};
        if isempty(segTitle)
            segTitle = '';
        end
        if contains(warbleSegments, segTitle)
            % Found one!
            hasAtLeastOneRequiredSegment = true;
            break;
        end
    end
    if hasAtLeastOneRequiredSegment
        % At least one good segment found
        % Now check if segments cover the required % of time

        % First get duration of the sound file
        [numSamples, ~] = obj.eg_GetSamplingInfo(filenum);

        % obj.dbase.SegmentTimes{filenum} is a Nx2 array of onset/offset sample numbers
        durations = diff(obj.dbase.SegmentTimes{filenum}, [], 2);
        totalDuration = sum(durations);

        SegmentPct = 100 * totalDuration / numSamples;
        if SegmentPct >= minTimePercentage
            % More than the minimum - mark it good!
            isGoodWarble = true;
        end
    end

    % Set property value
    obj.setPropertyValue(propertyName, isGoodWarble, filenum, false);

    % Count # of good files found
    goodWarbleCount = goodWarbleCount + isGoodWarble;
end
delete(progressBar);

% Let user know how many were found.
msgbox(sprintf('Found %d files with warble, out of %d.', goodWarbleCount, length(filenums)));

% Update GUI
obj.updateShowPropertyColumnMenu();
obj.UpdateFileInfoBrowser();
