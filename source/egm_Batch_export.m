function egm_Batch_export(obj)
% ElectroGui macro
% Export snippets that match criteria
arguments
    obj electro_gui
end

numFiles = electro_gui.getNumFiles(obj.dbase);

fileRangeString = ['1:' num2str(numFiles)];

inputs = getInputs('Parameters for batch exporting data visualizations:', ...
    {'File range to search', ...
     'Syllable match regex', ...
     'Event detection channel(s)', ...
     'Pre-match window margin (ms)', ...
     'Post-match window margin (ms)'}, ...
     {fileRangeString, ...
      '.*', ...
      '', ...
      '100', ...
      '100'}, ...
      {'Which files should we search for exporting - specify with a MATLAB expression that evaluates to a list of file numbers', ...
      'A regular expression to filter syllable titles with.', ...
      'A channel number or a 1D array of channel numbers for which events must coincide with the syllable for it to be exported. Leave blank to skip event filtering.', ...
      'Window of time before the start of the syllable to include in each exported window in ms (positive means before start)', ...
      'Window of time after the end of the syllable to include in each exported window in ms (positive means after end)', ...
      });

if isempty(inputs)
    return
end

filenums = eval(inputs{1});
syllableRegex = inputs{2};
% eventChannels = eval(inputs{3});
% preWindow = inputs{4};
% postWindow = inputs{5};

if ~isrow(filenums)
    filenums = transpose(filenums);
end

if ~isrow(filenums)
    error('File nums must be a 1D vector of file numbers');
end

progressBar = waitbar(0, 'Batch exporting...', 'WindowStyle', 'modal');

for k = 1:length(filenums)
    filenum = filenums(k);

    waitbar(k / length(filenums), progressBar);

    matches = regexpmatch(obj.dbase.SegmentTitles{filenum}, syllableRegex);
    if isempty(matches)
        continue;
    end
    starts = obj.dbase.SegmentTimes{filenum}(matches, 1);
    ends = obj.dbase.SegmentTimes{filenum}(matches, 2);
%     if ~isnan(eventChannel)
%         handles.EventTimes()
%     end

    if isempty(starts)
        continue;
    else
        obj.setFilenum(filenum);
    end

    [~, fs] = obj.eg_GetSamplingInfo(filenum);
    
    tab = obj.getExportFileTab(filenum);

    % Loop over syllables
    for j = 1:length(starts)
        tlim = [starts(j), ends(j)] ./ fs;
        obj.export(filenum, tlim, tab);
    end
end

close(progressBar);