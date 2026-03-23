function [data, fs, dateandtime, label, props] = egl_FP_vg(filename, loaddata)
% Vikram Gadagkar
% ElectroGui file loader
% Reads Fiber Photometry files
% Extracts date and time information from the time column

if loaddata
    fs = 40000;
    delimiterIn = '	';
    headerlinesIn = 4;
    A = importdata(filename,delimiterIn,headerlinesIn);
    data = A.data(:,1);
    dateandtime = datenum(A.textdata{1}(4:end));
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