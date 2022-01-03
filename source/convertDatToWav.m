function convertDatToWav(pathIn, fs, pathOut, scaleData)
% Convert an electro_gui dat file to a wav file.
%   pathIn -    the path to the .dat file, or a cell array of paths, or a
%       directory in which to search for dat files
%   fs -        (optional) sampling frequency. Default is 20000.
%   pathOut -   (optional) the desired path where the .wav file should go.
%       If omitted the file is stored at the same name with a .wav
%       extension. If a cell array is passed, it must have the same size as
%       pathIn. If pathIn is a cell array, and pathOut is given, it must be
%       a cell array.
%   scaleData - (optional) scale the data to fit in the allowable wav data
%       range of -1 to 1. If true, the data will be scaled. If false, the 
%       data will be clipped so the absolute value of any data point that
%       is greater than one will be reduced to 1. Default is true.

if exist(pathIn, 'dir')
    % pathIn is a directory. Find .dat files
    pathIn = findFilesByRegex(pathIn, '.*\.[dD][aA][tT]', false, true);
end

if ~iscell(pathIn)
    pathIn = {pathIn};
end

if ~exist('fs', 'var') || isempty(fs)
    fs = 20000;
end
if ~exist('pathOut', 'var') || isempty(pathOut)
    pathOut = {};
    for k = 1:length(pathIn)
        thisPathIn = pathIn{k};
        [path, name, ext] = fileparts(thisPathIn);
        if strcmpi(ext, '.wav')
            error('Input file already has a .wav extension. Please choose a .dat file.');
        end
        pathOut{k} = fullfile(path, [name, '.wav']);
    end
end
if ~exist('scaleData', 'var') || isempty(scaleData)
    scaleData = true;
end

for k = 1:length(pathIn)
    fprintf('Converting file %d of %d\n', k, length(pathIn));
    thisPathIn = pathIn{k};
    thisPathOut = pathOut{k};
    delimiterIn = ' ';
    headerlinesIn = 4;
    A = importdata(thisPathIn,delimiterIn,headerlinesIn);
    data = A.data(:,1);
    maxData = max(data(:));
    minData = min(data(:));
    if scaleData && (minData < -1 || maxData > 1)
        biggestOvershoot = max(abs([minData, maxData]));
        data = data / biggestOvershoot;
        fprintf('\tScaling data by a factor of %f...\n', biggestOvershoot);
    end
    % dateandtime = datenum(A.textdata{headerlinesIn-3,1});
    audiowrite(thisPathOut, data, fs);
end