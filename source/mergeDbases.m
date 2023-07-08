function dbase = mergeDbases(dbaseA, dbaseB)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mergeDbases: Merge two dbases.
% usage:  dbase = mergeDbases(dbaseA, dbaseB)
%
% where,
%    dbaseA is the first dbase
%    dbaseB is the second dbase
%
% electro_gui produces a dbase struct that contains a variety of data about
%   an array of data files. This function can be used to merge two dbases.
%
% Note that this does not currently do anything sophisticated if there are
%   conflicting values that can't be merged in the two dbases - it just
%   defaults to the value from the first dbase supplied (dbaseA). This is a
%   pretty blunt tool at the moment that mostly just merges the file lists.
%
% See also: electro_gui
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If user provides a path, use it to load the dbase
if ischar(dbaseA)
    s = load(dbaseA, 'dbase');
    dbaseA = s.dbase;
end
if ischar(dbaseB)
    s = load(dbaseB, 'dbase');
    dbaseB = s.dbase;
end

% Remove all data relating to the file or files given by position index fileIdx in
% the provided dbase.

dbase.PathName = dbaseA.PathName;
dbase.Times = [dbaseA.Times, dbaseB.Times];
dbase.FileLength = [dbaseA.FileLength, dbaseB.FileLength];
dbase.SoundFiles = [dbaseA.SoundFiles; dbaseB.SoundFiles];
for k = 1:length(dbaseA.ChannelFiles)
    dbase.ChannelFiles{k} = [dbaseA.ChannelFiles{k}; dbaseB.ChannelFiles{k}];
end
dbase.SoundLoader = dbaseA.SoundLoader;
dbase.ChannelLoader = dbaseA.ChannelLoader;
dbase.Fs = dbaseA.Fs;
dbase.SegmentThresholds = [dbaseA.SegmentThresholds, dbaseB.SegmentThresholds];
dbase.SegmentTimes = [dbaseA.SegmentTimes, dbaseB.SegmentTimes];
dbase.SegmentTitles = [dbaseA.SegmentTitles, dbaseB.SegmentTitles];
dbase.SegmentIsSelected = [dbaseA.SegmentIsSelected, dbaseB.SegmentIsSelected];
dbase.MarkerTimes = [dbaseA.MarkerTimes, dbaseB.MarkerTimes];
dbase.MarkerTitles = [dbaseA.MarkerTitles, dbaseB.MarkerTitles];
dbase.MarkerIsSelected = [dbaseA.MarkerIsSelected, dbaseB.MarkerIsSelected];

dbase.Properties.Names = [dbaseA.Properties.Names, dbaseB.Properties.Names];
dbase.Properties.Values = [dbaseA.Properties.Values, dbaseB.Properties.Values];
dbase.Properties.Types = [dbaseA.Properties.Types, dbaseB.Properties.Types];

dbase.EventSources = dbaseA.EventSources;
dbase.EventFunctions = dbaseA.EventFunctions;
dbase.EventDetectors = dbaseA.EventDetectors;
dbase.EventThresholds = dbaseA.EventThresholds;
dbase.EventTimes = dbaseA.EventTimes;
dbase.EventIsSelected = dbaseA.EventIsSelected;
dbase.AnalysisState = dbaseA.AnalysisState;
