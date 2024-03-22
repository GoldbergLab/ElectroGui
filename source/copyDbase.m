function dbase = copyDbase(dbase, newRootPath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copyDbase: Copy a dbase and its data to a new directory
% usage:  dbase = copyDbase(dbase, newRootPath)
%
% where,
%    dbase is a dbase struct generated by electro_gui, or the path to one
%    newRootPath is the path to the new desired root directory where the 
%    dbase and the files it references will be copied.
%
% electro_gui produces a dbase struct that contains a variety of data about
%   an array of data files. This function can be used to copy the dbase and
%   all the data it references to a new directory, as well as alter the
%   internal reference to the path, so the new dbase references the newly
%   copied files.
%
% As a convenience, the altered dbase is also returned so it doesn't need
%   to be loaded afterwards.
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
    originalDbaseName = dbase;
    s = load(dbase, 'dbase');
    dbase = s.dbase;
else
    originalDbaseName = 'dbase.mat';
end

fprintf('Moving dbase data from\n');
fprintf('    %s\n', dbase.PathName);
fprintf('to\n');
fprintf('    %s\n', newRootPath);
fprintf('\n')

numFileGroups = length(dbase.SoundFiles);
numChannels = length(dbase.ChannelFiles);

copyFails = 0;

% Loop over file groups
for k = 1:numFileGroups
    displayProgress('    Copying file group %d of %d\n', k, numFileGroups, 20);
    % If file struct array contains a "folder" field (depends on MATLAB
    % version used to generate it), alter it to reflect the new path.
    if isfield(dbase.SoundFiles, 'folder')
        dbase.SoundFiles(k).folder = newRootPath;
    end

    % Collect names of files to be moved in this file group
    names = cell(1, 1+numChannels);
    names{1} = dbase.SoundFiles(k).name;
    for c = 1:numChannels
        names{c+1} = dbase.ChannelFiles{c}(k).name;
        if isfield(dbase.ChannelFiles{c}, 'folder')
            % Alter channel folder names too, if necessary
            dbase.ChannelFiles{c}(k).folder = newRootPath;
        end
    end
    for n = 1:length(names)
        name = names{n};
        oldFilePath = fullfile(dbase.PathName, name);
        newFilePath = fullfile(newRootPath,    name);

        % Attempt to copy file, note if it fails.
        if ~exist(oldFilePath, 'file')
            copyFails = copyFails + 1;
        else
            try
                copyfile(oldFilePath, newFilePath);
            catch
                copyFails = copyFails + 1;
            end
        end
        
    end
end
if copyFails > 0
    warning('    Failed to copy %d of %d files', copyFails, length(dbase.SoundFiles) * );
end

newDbasePath = getNextAvailablePath(originalDbaseName, 3);

save(newDbasePath, 'dbase');

fprintf('Moving dbase complete');