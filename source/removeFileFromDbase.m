function dbase = removeFileFromDbase(dbase, fileIdx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% removeFileFromDbase: Remove data for file or files from dbase by index.
% usage:  dbase = removeFileFromDbase(dbase, fileIdx)
%
% where,
%    dbase is a dbase struct generated by electro_gui, or the path to one
%    fileIdx is one or more indices indicating which file or files to
%       remove data for.
%
% electro_gui produces a dbase struct that contains a variety of data about
%   an array of data files. This function can be used to remove all data
%   relating to one or more files in the dbase, given by the file index.
%   For example,
%
%       dbase = removeFileFromDbase(dbase, 11);
%
%   would remove data relating to the 11th file in the dbase, and
%
%       dbase = removeFileFromDbase(dbase, [11, 100, 177])
%
%   would remove data relating to the 11th, 100th, and 177th files from the
%   dbase.
%
%   Note that this function does NOT alter the dbase saved to disk - it
%   only alters the loaded structure. If you wish the changes to be saved
%   to disk, you'll have to run
%
%       save('path/to/dbase_file.mat', 'dbase')
%
%   afterwards.
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

% Remove all data relating to the file or files given by position index fileIdx in
% the provided dbase.

dbase.SoundFiles(fileIdx) = [];
dbase.FileLength(fileIdx) = [];
dbase.Times(fileIdx) = [];
dbase.SegmentTimes(fileIdx) = [];
dbase.SegmentTitles(fileIdx) = [];
dbase.SegmentIsSelected(fileIdx) = [];
dbase.MarkerTimes(fileIdx) = [];
dbase.MarkerTitles(fileIdx) = [];
dbase.MarkerIsSelected(fileIdx) = [];
for k = 1:length(dbase.ChannelFiles)
    dbase.ChannelFiles{k}(fileIdx) = [];
end
dbase.SegmentThresholds(fileIdx) = [];
dbase.Properties.Names(fileIdx) = [];
dbase.Properties.Values(fileIdx) = [];
dbase.Properties.Types(fileIdx) = [];