function [data, fs, dateandtime, label, props] = egl_Intan_Bin(filename, loaddata)
% Brian Kardon
% ElectroGui file loader
% Reads Intan data files saved as binary nc files (netCDF format)
% Extracts date and time information from the file

if loaddata == 1
    loadedData = readIntanNcFile(filename);
    fs = 1/loadedData.dt;
    data = loadedData.data;
    dateandtime = double(loadedData.time(1:6)');
    dateandtime(6) = dateandtime(6)+double(loadedData.time(7))/1000000;
    dateandtime = datenum(dateandtime);
    label = 'Voltage';
else
    data = [];
    fs = [];
    dateandtime = [];
    label = [];
end

props.Names = {};
props.Values = {};
props.Types = [];