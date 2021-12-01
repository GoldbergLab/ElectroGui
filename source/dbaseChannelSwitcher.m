function dbaseChannelSwitcher(oldDBasePath, newDBasePath, oldSoundNum, newSoundNum, oldChannelNums, newChannelNums, soundRegex, chanRegex)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dbaseChannelSwitcher: swap channel numbers in electro_gui dbase files
% usage:  dbaseChannelSwitcher(oldDBasePath, newDBasePath, oldSoundNum,
%                               newSoundNum, oldChannelNums, 
%                               newChannelNums, soundRegex, chanRegex)
%
% where,
%    oldDBasePath is the path to the original dbase file
%    newDBasePath is the desired path for the modified dbase file
%    oldSoundNum is the old sound channel number
%    newSoundNum is the new sound channel number
%    oldChannelNums is a list of old channel numbers to be switched
%    newChannelNums is a list of new channel numbers in corresponding order
%    soundRegex is an optional regex to specify the sound file numbering
%       format
%    chanRegex is an optional regex to specify the channel file numbering
%       format
%
% This is a script to modify the file numbering system in the file
%   references stored in an electro_gui dbase file. It is useful if you
%   have put a lot of work into a dbase file, then you for some reason
%   need to swap the channel numbers
%
%   For example:
%
%       dbaseChannelSwitcher('C:\Users\Glab\dbase.mat', 'C:\Users\Glab\dbase_switched.mat', 1, 0, [1, 0], [2, 1])
%
%   The above usage would take dbase.mat and save it as dbase_switched.mat
%   where any sound files referenced that end in chan1.wav would be changed
%   to refer to the same filename but ending in chan0.wav. Similarly,
%   channel file numbering will be mapped such that chan1 >> chan2, and
%   chan0 >> chan1.
%
% See also: <related functions>
%
% Version: <version>
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Brief description of what the function does
%   InputA - description
%   InputB - description
%   ...
%   InputN - description
%   OutputA - description
%   OutputB - description
%   ...
%   OutputN - description

if ~exist('chanRegex', 'var') || isempty(chanRegex)
    chanRegex = '(?<=_chan)([0-9]+)(?=\.[a-zA-Z]{3})';
end
if ~exist('soundRegex', 'var') || isempty(soundRegex)
    soundRegex = '(?<=_chan)([0-9]+)(?=\.[a-zA-Z]{3})';
end

% Load original dbase
s = load(oldDBasePath);
dbase = s.dbase;

% Loop over sound file references and update them
for groupIdx = 1:length(dbase.SoundFiles)
    newName = switchChannelNum(dbase.SoundFiles(groupIdx).name, oldSoundNum, newSoundNum, soundRegex);
    dbase.SoundFiles(groupIdx).name = newName;
end
% Loop over channel file references and update them
for channelIdx = 1:length(dbase.ChannelFiles)
    for groupIdx = 1:length(dbase.ChannelFiles{channelIdx})
        newName = switchChannelNum(dbase.ChannelFiles{channelIdx}(groupIdx).name, oldChannelNums, newChannelNums, chanRegex);
        dbase.ChannelFiles{channelIdx}(groupIdx).name = newName;
    end
end

% Save modified dbase to file
save(newDBasePath, 'dbase');

function newName = switchChannelNum(oldName, oldChannelNums, newChannelNums, chanRegex)
% Extract the file number
groups = regexp(oldName, chanRegex, 'tokens');
if ~isempty(groups)
    matches = groups{1};
    oldNum = str2double(matches{1});
    % Find which new num corresponds to this old num
    newNum = newChannelNums(oldChannelNums == oldNum);
    if isempty(newNum)
        % No mapping found for this number, so leave it the same.
        newName = oldName;
    else
        % Swap in new number for old number
        newName = regexprep(oldName, chanRegex, num2str(newNum));
    end
else
    newName = oldName;
end