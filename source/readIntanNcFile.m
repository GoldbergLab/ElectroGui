function data = readIntanNcFile(pathToFile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% readIntanNcFile: A function to read a binary netCDF format file
%   representing 1 channel of data from Intan.
%
% usage:  
%   data = readIntanNcFile(pathToFile)
%
% where,
%    pathToFile is a char array representing the path to a binary file
%    data is a struct containing the data in the .nc file in the following 
%       fields:
%           data.time - a 7-long time vector of the form
%               [year, month, day, hour, minute, second, microseconds]
%           data.dt - the sampling period in seconds
%           data.chan - the channel number of the signal
%           data.metaData - char array of channel metadata
%           data.data - a 1xN array of samples (the actual signal data)
%
% This function is designed to read a netCDF format binary file containing
%   a single channel of Intan ephys data plus various metadata
%
% See also: writeIntanNcFile, electro_gui, egl_Intan_Bin, 
%   convertIntanTxtToNc
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fields = {'time', 'dt', 'chan', 'metaData', 'data'};

for k = 1:length(fields)
    field = fields{k};
    data.(field) = ncread(pathToFile, field);
end
data.metaData = data.metaData';