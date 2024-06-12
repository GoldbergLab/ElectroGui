function handles = egm_Batch_export(handles)
% ElectroGui macro
% Export snippets that match criteria

fileRangeString = ['1:' num2str(handles.TotalFileNumber)];

inputs = getInputs('Parameters for batch exporting data visualizations:', ...
    {'File range to search', ...
     'Syllable match regex', ...
     'Pre-match window margin (ms)', ...
     'Post-match window margin (ms)'}, ...
     {fileRangeString, ...
      '.*', ...
      '100', ...
      '100'}, ...
      {'Which files should we search for exporting - specify with a MATLAB expression that evaluates to a list of file numbers', ...
      'A regular expression to filter syllable titles with.', ...
      'Window of time before the start of the syllable to include in each exported window in ms (positive means before start)', ...
      'Window of time after the end of the syllable to include in each exported window in ms (positive means after end)', ...
      });

if isempty(inputs)
    return
end

[filenums, syllableRegex, preWindow, postWindow] = inputs{:};

matchFileNums = [];
matchStartTimes = [];
matchEndTimes = [];

if ~isrow(filenums)
    filenums = transpose(filenums);
end

if ~isrow(filenums)
    error('File nums must be a 1D vector of file numbers');
end

for filenum = filenums
    matches = regexpmatch(handles.SegmentTitles{filenum}, syllableRegex);
    starts = handles.SegmentTimes{filenum}(matches, 1);
    ends = handles.SegmentTimes{filenum}(matches, 2);

    matchFileNums = [matchFileNums, filenum * ones(1, length(starts))];
    matchStartTimes = [matchStartTimes, starts' - preWindow];
    matchEndTimes = [matchEndTimes, ends' + postWindow];

end



