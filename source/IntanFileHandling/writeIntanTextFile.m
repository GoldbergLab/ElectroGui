function writeIntanTextFile(filepath, timeVector, deltaT, channel, metaData, data, overwrite)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% writeIntanTextFile: Create a data text file in electro_gui format
%
% usage:  
%   writeIntanTextFile(path, timeVector, deltaT, channel, metaData, data[, 
%                    overwrite])
%
% where,
%    filepath is a char array representing the path to save the text file
%       to. If the filepath lacks a file extension, '.txt' will be added.

%    timeVector is a time/date vector of the form 
%           [year, month, day, hour, minute, second, microseconds]
%       or
%           [year, month, day, hour, minute, fractionalSeconds]
%       or
%           A numerical serial datenum (see datenum function)
%    deltaT is a number indicating the sampling period in seconds
%    channel is an integer describing the channel number (not used)
%    metaData is a char array with whatever metaData you wish to include.
%       If it is over 64 characters, it will be truncated.
%    data is a 1xN numerical array, each element representing a single
%       ephys sample.
%    overwrite is an optional boolean flag indicating whether or not to
%       overwrite an existing file. Default false.
%
% This function is designed to write the provided 1D timeseries data and 
%   metadata to a text file. It is written with a single channel of Intan 
%   ephys data in mind, and is designed to produce files that can be read 
%   into electro_gui using a electro_gui text file loader script.
%
% See also: writeIntanNcFile, electro_gui, convertIntanTxtToNc
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('overwrite', 'var')
    % Set default value for overwrite flag
    overwrite = true;
end

date = sprintf('%s/%s/20%s', timeVector(2), timeVector(3), timeVector(1)); %extract date from rhd file
time = sprintf('%d:%02u:%f', abs(timeVector(4)), abs(timeVector(5)), abs(timeVector(6)));  %this gets updated within the text file

[path, filename, ext] = fileparts(filepath);
if isempty(ext)
    % No file extension found - add '.txt' on
    filepath = fullfile(path, [filename, '.txt']);
end

if ~overwrite && exist(filepath, 'file')
    % Overwrite is set to false, and file already exists
    fprintf('Skipping file %s because it already exists.\n', filepath);
    return
end

song_file_ID = fopen(filepath, 'w');

fprintf(song_file_ID,'%s\t%s\r\n', date, time);
fprintf(song_file_ID, metaData);
fprintf(song_file_ID,'%s%f\r\n\r\n', 'delta_t = ', deltaT);
fprintf(song_file_ID,'%f\r\n', data);

fclose(song_file_ID);
