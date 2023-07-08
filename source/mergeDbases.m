function dbase = mergeDbases(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mergeDbases: Merge multiple dbases.
% usage:  dbase = mergeDbases(newDbase, dbase, ..., dbaseN)
%
% where,
%    newDbase is the first dbase
%    dbase is the second dbase
%    dbaseN is the nth dbase
%
% electro_gui produces a dbase struct that contains a variety of data about
%   an array of data files. This function can be used to merge dbases.
%
% Note that this does not currently do anything sophisticated if there are
%   conflicting values that can't be merged in the dbases - it just
%   defaults to the value from the first dbase supplied (newDbase). This is a
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
for k = nargin:-1:1
    if ischar(varargin{k})
        s = load(newDbase, 'dbase');
        newDbase = s.dbase;
    else
        newDbase = varargin{k};
    end

    if k == nargin
        dbase = newDbase;
        continue;
    end
    
    dbase.PathName = newDbase.PathName;
    dbase.Times = [newDbase.Times, dbase.Times];
    dbase.FileLength = [newDbase.FileLength, dbase.FileLength];
    dbase.SoundFiles = [newDbase.SoundFiles; dbase.SoundFiles];
    for k = 1:length(newDbase.ChannelFiles)
        dbase.ChannelFiles{k} = [newDbase.ChannelFiles{k}; dbase.ChannelFiles{k}];
    end
    dbase.SoundLoader = newDbase.SoundLoader;
    dbase.ChannelLoader = newDbase.ChannelLoader;
    dbase.Fs = newDbase.Fs;
    dbase.SegmentThresholds = [newDbase.SegmentThresholds, dbase.SegmentThresholds];
    dbase.SegmentTimes = [newDbase.SegmentTimes, dbase.SegmentTimes];
    dbase.SegmentTitles = [newDbase.SegmentTitles, dbase.SegmentTitles];
    dbase.SegmentIsSelected = [newDbase.SegmentIsSelected, dbase.SegmentIsSelected];
    dbase.MarkerTimes = [newDbase.MarkerTimes, dbase.MarkerTimes];
    dbase.MarkerTitles = [newDbase.MarkerTitles, dbase.MarkerTitles];
    dbase.MarkerIsSelected = [newDbase.MarkerIsSelected, dbase.MarkerIsSelected];
    
    dbase.Properties.Names = [newDbase.Properties.Names, dbase.Properties.Names];
    dbase.Properties.Values = [newDbase.Properties.Values, dbase.Properties.Values];
    dbase.Properties.Types = [newDbase.Properties.Types, dbase.Properties.Types];
    
    dbase.EventSources = newDbase.EventSources;
    dbase.EventFunctions = newDbase.EventFunctions;
    dbase.EventDetectors = newDbase.EventDetectors;
    dbase.EventThresholds = newDbase.EventThresholds;
    dbase.EventTimes = newDbase.EventTimes;
    dbase.EventIsSelected = newDbase.EventIsSelected;
    dbase.AnalysisState = newDbase.AnalysisState;
end