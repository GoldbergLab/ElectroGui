function potential_hb_struct = make_headbob_struct(root, filename, filenum, options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_headbob_struct: Create an info struct for each potential headbob
% usage: potential_hb_struct = make_headbob_struct(root, filename, filenum,
%                                                   options.AccelFs)
%
% where,
%    root is the folder containing the accelerometer data
%    filename is the filename of the accelerometer data
%    filenum is the number of the file within the electro_gui database
%    Name/Value options can include:
%       AccelFs: the sampling rate of the accelerometer data. Default is 
%           5000
%       Loader: A function handle for loading the data. Default is 
%           @egl_Intan_Nc
%       Data: A 1xN timeseries of accelerometer data. If this is supplied,
%           then data is not loaded from the file
%    potential_hb_struct is a struct containing information about potential 
%       headbobs
%
% <long description>
%
% See also: cj_dbase_hb_accel_detect_with_curation, detect_headbobs_acc,
%           electro_gui
%
% Version: 1.0
% Author:  Caleb Jones, modified slightly by Brian Kardon
% Email:   cj397=cornell*org
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
arguments
    root
    filename
    filenum
    options.AccelFs = 5000
    options.Loader = @egl_Intan_Nc
    options.Data = []
end

potential_hb_struct = [];

pad_seconds = 3;
pad = pad_seconds * options.AccelFs;

if isempty(options.Data)
    filepath = fullfile(root, filename);
    
    % load the file
    movez = options.Loader(filepath, 1);
else
    % User passed a vector of data, just use it
    movez = options.Data;
end

% Skip files shorter than 5s
if length(movez)/options.AccelFs >= 5
    % do the detect
    hb_detects = detect_headbobs_acc(movez, options.AccelFs);
    if ~isempty(hb_detects.onsets)
        % Found at least one potential headbob
        for hb_num = 1:length(hb_detects.onsets)
            % Find region around headbob detect onset/offset
            samps = [max(1, hb_detects.onsets(hb_num)  - pad), ...
                     min(   hb_detects.offsets(hb_num) + pad, length(hb_detects.aa1))
                    ];
            % get individual cycles
            [~, locs] = findpeaks(hb_detects.aa1(hb_detects.onsets(hb_num):hb_detects.offsets(hb_num)), 'MinPeakDistance', 500, 'MinPeakHeight', 0);
            if locs(1)<200
                locs = locs(2:end);
            end
            % Record headbob info
            potential_hb_struct(hb_num).onset = hb_detects.onsets(hb_num); %#ok<*AGROW>
            cyc_abs = (hb_detects.onsets(hb_num) - 1) + locs;  % absolute indices in full file
            potential_hb_struct(hb_num).cyc_abs = cyc_abs;
            potential_hb_struct(hb_num).offset = hb_detects.offsets(hb_num);
            potential_hb_struct(hb_num).aa1 = hb_detects.aa1(samps(1):samps(2));
            potential_hb_struct(hb_num).cfs = hb_detects.cfs(:, samps(1):samps(2));
            potential_hb_struct(hb_num).filename = filename;
            potential_hb_struct(hb_num).filenum = filenum;
            potential_hb_struct(hb_num).samp0 = samps(1);
        end
    end
end