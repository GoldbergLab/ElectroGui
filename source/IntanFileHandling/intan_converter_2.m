function intan_converter_2(acc_array, path_input, start_index, audio_threshold, writer, verbose)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% intan_converter_2: Convert Intan .rhd files to binary .nc channel files
% usage:  intan_converter_2(acc_array, path_input, start_index, 
%                           audio_threshold, writer)
%         intan_converter_2(acc_array, path_input, start_index, 
%                           audio_threshold, writer, verbose)
%
% where,
%    acc_array is a 1xN array of boolean values, where N is the number of
%       headstages in the .rhd files. Each value in the array indicates
%       whether or not the headstage at that index has accelerometer data.
%    path_input is an optional char array representing a path to a
%       directory in which to look (non-recursively) for .rhd files. If
%       this argument is omitted, or is an empty array, then the user will
%       be prompted to select a directory in a popup.
%    start_index is an optional integer indicating which intan .rhd file to
%       begin conversion at within the directory
%    audio_threshold is an optional floating point number indicating what
%       volume threshold to use to trigger file recording
%    writer is a function handle to a function that writes the data. Two
%       scripts current available are writeIntanNcFile and 
%       writeIntanTextFile
%    verbose is an optional boolean flag indicating whether or not to
%       produce extra informational output during processing
%
% This function takes Intan .rhd files and splits them into individual
%   binary .nc channel files. Within the rhd search directory, it creates a
%   "Data Extracted" folder, and within that N "HeadstageK" directories,
%   where K is the headstage number, which goes from 1 to N, the number of
%   headstages. For example: 
%
%   path_input
%       Data Extracted
%           Headstage1
%               convertedNcFile1.nc
%               convertedNcFile2.nc
%               ...
%               convertedNcFileN.nc
%           Headstage2
%               convertedNcFile1.nc
%               convertedNcFile2.nc
%               ...
%               convertedNcFileN.nc
%
%   Within each Headstage directory, it will write the
%   converted .nc files. These .nc files are designed to be loaded into
%   electro_gui using the 'egl_Intan_Nc.m' loader script.
%
% See also: egl_Intan_Nc, writeIntanNcFile, writeIntanTextFile,
%   read_Intan_RHD2000_file_to_struct
%
% Version: 1.0
% Author:  Intan Technologies, Anindita Das, Vikram Gadagkar, Brian Kardon,
%   possibly others
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Brian Kardon, modified April 2022 to write either .nc binary files or .txt files

% Anindita Das, July 2018, edited on August 2019 for 'song-searching'.
% Reads and extracts Intan files and saves into text files with date and time
% Checks the value of analog signal and whenever it crosses a threshold (say time t), it saves the 2 analog channel data
% accelerator data if present and 16 amplifier channel data for (t-5)s to(t+5) sec.
% uses the date, time and filename extracted from rhd file to create the
% .txt file name

% first goes into the directory and extracts date & time info from the first
% rhd file. It then loops through all the rhd files in that folder and
% looks through the analog channel data first.
% One directory correspondes to one recording session/day and
% so time stamp is contiguous across the rhd files (t_amplifier data) in that directory. Hence
% all time stamps in the txt files is calculated based on the time of the
% first rhd file and the incremental time step of the t_amplifier array.

% Modified for multiple headstages with accelerometers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Apply defaults if necessary
if ~exist('path_input', 'var') || isempty(path_input)
    path_input = ...
        uigetdir('.', 'Select RHD data folder for extraction');  % directory where the rhd files to be analysed are stored
end
if ~exist('start_index', 'var') || isempty(start_index)
    start_index = 1;
end
if ~exist('audio_threshold', 'var') || isempty(audio_threshold)
    audio_threshold = 0.3;
end
if ~exist('writer', 'var') || isempty(writer)
    writer = @writeIntanNcFile;
end
if ~exist('verbose', 'var') || isempty(verbose)
    verbose = 0;
end

%% Define constants

% Predefined channel numbers
song_channel = 0;
eff_copy_channel = 17;
acc1_channel = 18;
acc2_channel = 19;
acc3_channel = 20;
max_timestamp_discrepancy = 60;

buffer_start = 2 ; % time (sec) before analog signal crosses threshold first time in one adc channel data file
buffer_end = 10;  % time (sec) after first threshold crossing of analog signal

% Variable to count how many times intan timestamp overflows and rolls over
num_rollovers = 0;
last_t_amplifier = [];

channel_count = 16; %(figure out a way to NOT hard code this)rhd files don't save the number of headstages being recorded from, but all amp channels are saved as a continuous series
unit = 1e-6;     % conversion factor (Intan amplifier data is in microvolt, digital and analog inputs are in Volts)


%% Find RHD files
fprintf('Looking for rhd files in: \n\t ''%s''\n', path_input);
% Get a list of all *.rhd files in the input directory
rhd_file_list = dir(fullfile(path_input, '*.rhd'));
% Store the name of the first RHD file in the directory
first_rhd_filename = rhd_file_list(start_index).name;
% Extract time and date from first rhd file name
first_file_timestamp = get_rhd_filename_timestamp(first_rhd_filename);
first_rhd_date_string = format_rhd_date(first_file_timestamp);
% Get base name from first RHD filename to make sure all files belong in
% the same data series
first_base_name = get_rhd_base_name(first_rhd_filename);

%% Loop over RHD files, look for audio over the threshold, and save channel files 
for file_num = start_index:numel(rhd_file_list)    % goes through all rhd files in one directory (one recording session)
    fprintf('Reading rhd file %d of %d\n', file_num, numel(rhd_file_list));

    % Get RHD filename
    rhd_filename = rhd_file_list(file_num).name;

    % Read RHD data from file into the data struct
    data = read_Intan_RHD2000_file_to_struct_2(path_input, rhd_filename, verbose);       %reads *rhd files into a data struct.

    if file_num == start_index
        %% Collect information from the first RHD file
        % Get the amplifier sampling rate and period
        fs = data.frequency_parameters.amplifier_sample_rate;
        delta_t = 1 / fs;
        % Get the amplifier timestamp of the first sample of the first file
        % in the directory
        start_t_amplifier = data.t_amplifier(1);
        % Determine how many headstages are present
        num_headstages = size(data.amplifier_channels, 2) / channel_count;

        % Size of window for moving window averaging when detecting volume
        % threshold crossings
        window_size = round(fs / 1000);

        for headstage_num = 1:num_headstages
            %% Create output directories
            % New directory where extracted files will be stored
            path_output_base = fullfile(path_input, 'Data_extracted');

            % Create alternative extracted file directory if this one 
            %   already exists.
            attempt_num = 2;
            while isdir(path_output_base)
                path_output_base = fullfile(path_input, sprintf('Data_extracted_%d', attempt_num));
                attempt_num = attempt_num + 1;
            end
        end
        
        session_chunk_nums = zeros(1, num_headstages);
    
    end

    % Check that RHD base name matches the base name of the 1st RHD file
    base_name = get_rhd_base_name(rhd_filename);
    if ~strcmp(base_name, first_base_name)
        warning(['RHD base name changed: \n', ...
               'RHD file num: %d\n', ...
               'RHD file name:     %s\n', ...
               '1st RHD file name: %s\n'], ...
               file_num, rhd_filename, first_rhd_filename);
    end
    
    % Check that amplifier-based-timestamp does not differ
    % significantly from rhd-filename-based-timestamp
    rhd_filename_timestamp = get_rhd_filename_timestamp(rhd_filename);
    rhd_amplifier_timestamp = get_rhd_amplifier_timestamp(data.t_amplifier(1), first_file_timestamp, start_t_amplifier);
    
    timestampDiscrepancy = abs(rhd_filename_timestamp - rhd_amplifier_timestamp);
    if timestampDiscrepancy > max_timestamp_discrepancy
        error(['Error! Amplifier and filename timestamps don''t match: \n', ...
               'RHD file num: %d\n', ...
               'RHD file name: %s\n', ...
               'RHD filename timestamp:  %s\n', ... 
               'RHD amplifier timestamp: %s\n'], ...
               file_num, rhd_filename, num2str(round(datevec(rhd_filename_timestamp/(24*60*60)))), num2str(round(datevec(rhd_amplifier_timestamp/(24*60*60)))));
    end
    
    rhd_time_string = format_rhd_time(rhd_filename_timestamp);

    % Fix intan t_amplifier overflow/rollover issue
    [data.t_amplifier, num_rollovers, last_t_amplifier] = fix_t_amplifier(data.t_amplifier, num_rollovers, last_t_amplifier, fs);
    
    n_acc = 0;
    if (file_num==start_index) && (isfield(data, 'aux_input_channels'))
        number_aux = size(data.aux_input_channels, 2);
        % Get the aux sample rate, which is different from the amplifier
        % sample rate
        fs_aux = data.frequency_parameters.aux_input_sample_rate;
    end
    
    for headstage_num = 1:num_headstages
        %% Loop over each headstage in this file
        fprintf('\tHandling headstage %d of %d\n', headstage_num, num_headstages);

        % Construct a headstage output subdirectory
        path_output = fullfile(path_output_base, sprintf('Headstage%d', headstage_num));

        % Create headstage folder
        [success, msg, err] = mkdir(path_output);
        if ~success
            error('Error while making headstage subfolder:\n%s\n%s', err, msg);
        end
        
        if acc_array(headstage_num)==1
            n_acc=n_acc+1;
        end

        % Find all periods within this file and this headstage with sound
        % that is over the designated threshold.
        [chunk_starts, chunk_ends] = generate_file_chunk_times(data.board_adc_data(headstage_num, :), audio_threshold, window_size, buffer_start*fs, buffer_end*fs);
        
        for chunk_num = 1:length(chunk_starts)
            %% Loop over all chunks of data which contain audio over the threshold.
            chunk_start = chunk_starts(chunk_num);
            chunk_end = chunk_ends(chunk_num);
            
            % Increment the overall session chunk count for this headstage
            session_chunk_nums(headstage_num) = session_chunk_nums(headstage_num) + 1;

            % Construct a filename pattern. Note that the writer function
            % will add the appropriate file extension
            filename_pattern = sprintf('d%07u_%sT%s_chan%%d', session_chunk_nums(headstage_num), first_rhd_date_string, rhd_time_string);

            % Determine the timestamp of the first sample of this chunk
            chunk_timestamp = get_rhd_amplifier_timestamp(data.t_amplifier(chunk_start), first_file_timestamp, start_t_amplifier);
            
            % Convert the timestamps to a date vector
            [chunk_year, chunk_month, chunk_day, chunk_hour, chunk_minute, chunk_second] = get_rhd_time_components(chunk_timestamp);
            
            % Construct a filename for the song file
            song_filename = sprintf(filename_pattern, song_channel);
            full_song_filename = fullfile(path_output, song_filename);

            % Construct a filename for the efference copy file
            eff_copy_filename = sprintf(filename_pattern, eff_copy_channel);
            eff_copy_file_path = fullfile(path_output, eff_copy_filename);
            
            % Assemble song information to prepare for writing
            song_data.timeVector = abs([chunk_year, chunk_month, chunk_day, chunk_hour, chunk_minute, chunk_second]);
            song_data.metaData = sprintf('%s\t%s%d\r\n', rhd_file_list(file_num).name, 'Motif file', chunk_num);
            song_data.deltaT = delta_t;
            song_data.data = data.board_adc_data(headstage_num, chunk_start:chunk_end);

            % Write the song and possibly the efference copy to file
            writer(full_song_filename, song_data.timeVector, song_data.deltaT, song_channel, song_data.metaData, song_data.data, true);

            % If no digital signals are present (typically DAF EC
            % signal) then don't bother recording them. Because it
            % won't work. Because they aren't there.
            record_eff_copy = isfield(data, 'board_dig_in_data');
            if record_eff_copy
                eff_copy_data = song_data;
                eff_copy_data.data = data.board_dig_in_data(headstage_num, chunk_start:chunk_end);
                writer(eff_copy_file_path, eff_copy_data.timeVector, eff_copy_data.deltaT, eff_copy_channel, eff_copy_data.metaData, eff_copy_data.data, true);
            end

            fprintf('\t\tWriting chunk: %f seconds, #%d\n', length(song_data.data)/fs, chunk_num);

            if acc_array(headstage_num)==1
                %% Write accelerometer data
                
                % Translate chunk start/end to the aux_input_data timebase
                % (which runs at a slower frequency than the amplifier
                % timebase)
                chunk_start_aux = round(fs_aux * (chunk_start - 1)/ fs) + 1;
                chunk_end_aux = round(fs_aux * (chunk_end - 1) / fs) + 1;
                
                % Handle the edge case where the amplifier => aux timebase
                % conversion ends up with a sample number that is one
                % sample too large
                if chunk_end_aux > size(data.aux_input_data, 2)
                    chunk_end_aux = size(data.aux_input_data, 2);
                end

                % Generate accelerometer filenames
                accfile1_name = sprintf(filename_pattern, acc1_channel);
                full_acc1_filename = fullfile(path_output, accfile1_name);

                accfile2_name = sprintf(filename_pattern, acc2_channel);
                full_acc2_filename = fullfile(path_output, accfile2_name);

                accfile3_name = sprintf(filename_pattern, acc3_channel);
                full_acc3_filename = fullfile(path_output, accfile3_name);

                % Assemble acceleromater information to prepare for writing
                acc1.timeVector = abs([chunk_year, chunk_month, chunk_day, chunk_hour, chunk_minute, chunk_second]);
                acc1.metaData = sprintf('%s\t%s%d\r\n', rhd_file_list(file_num).name, 'Motif file', chunk_num);
                acc1.deltaT = delta_t;

                % Copy metadata to other accelerometer channels
                acc2 = acc1;
                acc3 = acc1;
                
                % Copy accelerometer data into save structure
                acc1.data = data.aux_input_data((3*n_acc-2), chunk_start_aux:chunk_end_aux);
                acc2.data = data.aux_input_data((3*n_acc-1), chunk_start_aux:chunk_end_aux);
                acc3.data = data.aux_input_data((3*n_acc),   chunk_start_aux:chunk_end_aux);

                % Save accelerometer data & metadata to file
                writer(full_acc1_filename, acc1.timeVector, acc1.deltaT, acc1_channel, acc1.metaData, acc1.data, true);
                writer(full_acc2_filename, acc2.timeVector, acc2.deltaT, acc2_channel, acc2.metaData, acc2.data, true);
                writer(full_acc3_filename, acc3.timeVector, acc3.deltaT, acc3_channel, acc3.metaData, acc3.data, true);

            end

            channel_num = 1;
            % Loop over channel data for this headstage (channel data is
            % not segregated by headstage in rhd file)
            for rhd_channel_idx = (channel_count*(headstage_num-1)+1):(channel_count*headstage_num)
                % Generate channel filenames
                file_name = sprintf(filename_pattern, channel_num);
                full_file_name = fullfile(path_output, file_name);

                % Generate channel metadata
                otherChannel.timeVector = abs([chunk_year, chunk_month, chunk_day, chunk_hour, chunk_minute, chunk_second]);
                otherChannel.metaData = sprintf('%s\t%s%d\r\n', rhd_file_list(file_num).name, 'Motif file', chunk_num);
                otherChannel.deltaT = delta_t;

                % Copy channel data into struct
                otherChannel.data = data.amplifier_data(rhd_channel_idx, chunk_start:chunk_end) * unit;
                
                % Notch filter data for 60 Hz noise
                otherChannel.data = notch_filter(otherChannel.data, fs, data.notch_filter_frequency, 10);

                % Save channel data & metadata to file
                writer(full_file_name, otherChannel.timeVector, otherChannel.deltaT, rhd_channel_idx, otherChannel.metaData, otherChannel.data, true);

                channel_num = channel_num+1;
            end
        end
    end
end



function out = notch_filter(in, fSample, fNotch, Bandwidth)

% out = notch_filter(in, fSample, fNotch, Bandwidth)
%
% Implements a notch filter (e.g., for 50 or 60 Hz) on vector 'in'.
% fSample = sample rate of data (in Hz or Samples/sec)
% fNotch = filter notch frequency (in Hz)
% Bandwidth = notch 3-dB bandwidth (in Hz).  A bandwidth of 10 Hz is
%   recommended for 50 or 60 Hz notch filters; narrower bandwidths lead to
%   poor time-domain properties with an extended ringing response to
%   transient disturbances.
%
% Example:  If neural data was sampled at 30 kSamples/sec
% and you wish to implement a 60 Hz notch filter:
%
% out = notch_filter(in, 30000, 60, 10);

tstep = 1/fSample;
Fc = fNotch*tstep;

L = length(in);

% Calculate IIR filter parameters
d = exp(-2*pi*(Bandwidth/2)*tstep);
b = (1 + d*d)*cos(2*pi*Fc);
a0 = 1;
a1 = -b;
a2 = d*d;
a = (1 + d*d)/2;
b0 = 1;
b1 = -2*cos(2*pi*Fc);
b2 = 1;

out = zeros(size(in));
out(1) = in(1);
out(2) = in(2);
% (If filtering a continuous data stream, change out(1) and out(2) to the
%  previous final two values of out.)

% Run filter
for i=3:L
    out(i) = (a*b2*in(i-2) + a*b1*in(i-1) + a*b0*in(i) - a2*out(i-2) - a1*out(i-1))/a0;
end

return

function [chunk_starts, chunk_ends] = generate_file_chunk_times(sound, audio_threshold, window_size, pre_buffer_samples, post_buffer_samples)
% Sound is a 1 x N vector of audio data, where N is the number of samples
audio_levels = conv(abs(sound), ones(1, window_size)/window_size, 'same');
audio_high = audio_levels > audio_threshold;
k = 1;
total_samples = numel(sound);
chunk_starts = [];
chunk_ends = [];
while true
    k = find(audio_high(k:end), 1) + k - 1;
    if isempty(k)
        % No more high audio samples found - stop looking for chunks
        break;
    end
    chunk_start = k - pre_buffer_samples;
    chunk_start = max(chunk_start, 1);
    chunk_end = k + post_buffer_samples;
    chunk_end = min(chunk_end, total_samples);
    chunk_starts(end+1) = chunk_start;
    chunk_ends(end+1) = chunk_end;
    k = k + post_buffer_samples + 1;
end

function rhd_date_string = format_rhd_date(timestamp)
% Convert a scalar timestamp in seconds since epoch to a output file
% datestamp

[year, month, day] = get_rhd_time_components(timestamp);

rhd_date_string = sprintf('%04d%02d%02d', year, month, day);

function rhd_time_string = format_rhd_time(timestamp)
% Convert a scalar timestamp in seconds since epoch to a output file
% timestamp

[~, ~, ~, hour, minute, second] = get_rhd_time_components(timestamp);

rhd_time_string = sprintf('%02d%02d%02d', hour, minute, round(second));

function [year, month, day, hour, minute, second] = get_rhd_time_components(timestamp)
% Convert a scalar timestamp in seconds since epoch to data components

[year, month, day, hour, minute, second] = datevec(timestamp/(60*60*24));

function timestamp = get_rhd_amplifier_timestamp(t_amplifier, start_timestamp, start_t_amplifier)
% Extract timestamp from rhd amplifier time in seconds since epoch

timestamp = start_timestamp + t_amplifier - start_t_amplifier;

function timestamp = get_rhd_filename_timestamp(rhd_filename)
% Extract timestamp from rhd file name in seconds since epoch

tokens = regexp(rhd_filename, '(.*)_([0-9]{2})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\.[rR][hH][dD]', 'tokens');
% Remove basename, which is the first token:
tokens{1}(1) = [];

tokens = cellfun(@str2double, tokens{1}, 'UniformOutput', true);
% Convert 2 digit year to 4 digit year
tokens(1) = tokens(1) + 2000;
% Convert vector time to scalar time
timestamp = datenum(tokens(:)') * 60 * 60 * 24;

function base_name = get_rhd_base_name(rhd_filename)
% Extract the base name from an RHD filename

tokens = regexp(rhd_filename, '(.*)_([0-9]{2})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\.[rR][hH][dD]', 'tokens');
base_name = tokens{1}{1};

function [t_amplifier, num_rollovers, last_t_amplifier] = fix_t_amplifier(t_amplifier, num_rollovers, last_t_amplifier, fs)
% Intan has a problem where if you record for more than ~22 hours, the
%   t_amplifier field overflows and becomes negative, because intan used a
%   int32 field to store the timestamps. Therefore we need to count how 
%   many rollovers have occurred, and adjust the t_amplifier timestamps 
%   accordingly.

rollover_correction = (2^32) / fs;

% Look for a discontinuity in the t_amplifier field
jump_point = find(round(abs(diff([last_t_amplifier, t_amplifier])) * fs) > 1) + length(last_t_amplifier) - 1;
if isempty(jump_point)
    % No rollover detected
    jump_point = 1;
else
    % Uh oh, stupid Intan rolled over the t_amplifier times
    disp('ROLLOVER DETECTED...COMPENSATING...');

    % This is the point where the time field rolls over again
    num_rollovers = num_rollovers + 1;
end

% Correct t_amplifier time based on how many rollovers have accumultae
t_amplifier(1:jump_point-1) = t_amplifier(1:jump_point-1) + num_rollovers * rollover_correction;

% Correct t_amplifier time based on how many rollovers have accumultae
t_amplifier(jump_point:end) = t_amplifier(jump_point:end) + num_rollovers * rollover_correction;

% Return last timestamp so we can tack it on to the beginning of the next
% time series to check for rollovers just before the first sample of the
% next file
last_t_amplifier = t_amplifier(end);
