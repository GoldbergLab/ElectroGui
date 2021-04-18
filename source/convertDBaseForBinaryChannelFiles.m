function convertDBaseForBinaryChannelFiles(dbasePath, convertIfNotFound, keepOldDBaseFile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convertDBaseForBinaryChannelFiles: rewrite preexisting dbase files to 
%   reflect file conversions from .txt to binary .nc files.
%
% usage: convertDBaseForBinaryChannelFiles(dbasePath, convertIfNotFound, 
%                                          keepOldDBaseFile)
%
% where,
%    dbasePath is the path to the dbase file to be converted
%    convertIfNotFound is a boolean flag indicating whether or not to
%       convert .txt files referenced in the dbase to .nc files.
%    keepOldDBaseFile is a boolean flag indicating whether to keep the 
%       original dbase file (under a modified name), or just overwrite it.
%
% This function is designed to update preexisting electro_gui dbase files 
%   to reflect conversions of the referenced channel files from .txt files 
%   to binary .nc files. It takes a path to a dbase file, looks through the
%   file paths stored inside the dbase file, and changes them from
%   references to .txt files to equivalently named .nc files. It can also
%   convert the .txt files referenced to .nc files if desired, unless the
%   .nc file in question already exists.
%
% See also: electro_gui, writeIntanNcFile, readIntanNcFile, egl_Intan_Bin
%   intan_converter_to_binary_channel_files 
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbase = load(dbasePath);
dbase = dbase.dbase;

fprintf('%d sound files registered in dbase. Converting...\n', length(dbase.SoundFiles));
for k = 1:length(dbase.SoundFiles)
    dbase.SoundFiles(k) = swapInBinaryFile(dbase.PathName, dbase.SoundFiles(k).name, 'sound', convertIfNotFound);
end
fprintf('...done handling sound files.\n');

fprintf('%d other channel files registered in dbase. Converting...\n', length(dbase.SoundFiles));
for chan = 1:length(dbase.ChannelFiles)
    for k = 1:length(dbase.ChannelFiles{chan})
        dbase.ChannelFiles{chan}(k) = swapInBinaryFile(dbase.PathName, dbase.ChannelFiles{chan}(k).name, sprintf('chan%d', chan), convertIfNotFound);
    end
end
fprintf('...done handling other channel files.\n');

dbase.SoundLoader = 'Intan_Bin';
dbase.ChannelLoader = cellfun(@(x)'Intan_Bin', dbase.ChannelLoader, 'UniformOutput', false);

if keepOldDBaseFile
    [dbaseDir, dbaseName, dbaseExt] = fileparts(dbasePath);
    newDbasePath = fullfile(dbaseDir, [dbaseName, '_txt', dbaseExt]);
    movefile(dbasePath, newDbasePath);
end
save(dbasePath, 'dbase');


function newDirEntry = swapInBinaryFile(basePath, txtFileName, displayName, convertIfNotFound)
channelPath = fullfile(basePath, txtFileName);
if ~exist(channelPath, 'file')
    fprintf('Warning, original %s file ''%s'' not found\n', displayName, channelPath);
    fprintf('Perhaps it has been deleted or moved, or is not accessible? Carrying on...\n');
end
newChannelPath = replaceExt(channelPath, '.txt', '.nc');
if ~exist(newChannelPath, 'file')
    fprintf('Converted binary %s file ''%s'' not found.\n', displayName, newChannelPath);
    if convertIfNotFound
        fprintf('Converting to binary %s file...\n', displayName);
        convertIntanTxtToNc(channelPath);
        fprintf('...done converting to binary %s file\n', displayName);
    end
else
    fprintf('Converted binary file found.\n');
end
if exist(newChannelPath, 'file')
    newDirEntry = dir(newChannelPath);
else 
    [~, newChannelName, newChannelExt] = fileparts(newChannelPath);
    newDirEntry.name = [newChannelName, newChannelExt];
    newDirEntry.date = '';
    newDirEntry.bytes = 0;
    newDirEntry.isDir = 0;
    newDirEntry.datenum = 0;
end

function newPath = replaceExt(path, oldExt, newExt)
if (oldExt(1) ~= '.')
    % Ensure extension starts with a '.'
    oldExt = ['.', oldExt];
end
if (newExt(1) ~= '.')
    % Ensure extension starts with a '.'
    newExt = ['.', newExt];
end
[dir, name, ext] = fileparts(path);
if ~strcmp(ext, oldExt)
    error('Old extension was expected to be %s, but instead was %s', oldExt, ext);
end
newPath = fullfile(dir, [name, newExt]);