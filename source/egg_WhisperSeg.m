function [segmentTimes, segmentTitles] = egg_WhisperSeg(data, ~, fs, ~, params)
% ElectroGui segmenter
% This segmenter uses WhisperSeg
% (https://github.com/nianlonggu/WhisperSeg/tree/master) to segment the
% audio data into syllables. It requires a WhisperSeg web service to be
% running either locally or remotely.

% Define default segmenter parameters
defaultParams.Names =  {'WhisperSeg hostname/IP',       'WhisperSeg service port',  'Mininum frequency (Hz)',   'Spectrogram time step (s)',    'Minimum segment length (s)',   'Tolerance',   'eps',  'time_per_frame_for_scoring', 'Number of trials', 'Network name',                            'Use labels'};
defaultParams.Values = {'goldbergbk.nbb.cornell.edu',   '8050',                     '0',                        '0.0025',                       '0.01',                         '0.01',        '0.02', '0.001',                      '3',                '20240907_ZhileiEphysWarble20kFinetune3',   'true'};

segmentTitles = {};

% Check if the user passed in the string "params" instead of audio data
if exist('data', 'var') && istext(data)
    if strcmp(data,'params')
        % Return the default parameters
        segmentTimes = defaultParams;
        return
    elseif exist(data, 'file')
        % User has passed in a path - load the data
        [data, fs] = audioread(data);
    end
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

% Extract the parameters chosen
[host, port, min_frequency, spec_time_step, min_segment_length, tolerance, eps, time_per_frame_for_scoring, num_trials, network_name, use_labels] = params.Values{:};

if ischar(data) && strcmp(data, 'list')
    % If only one argument - 'list' - is passed, query the service for what
    % the available models are.
    clear segmentTimes segmentTitles
    service_url = sprintf('http://%s:%s/models', host, port);
    fprintf('Attempting to get a list of available trained WhisperSeg models host %s at port %s...\n\n', host, port)
    try
        options = weboptions('RequestMethod', 'POST', 'MediaType', 'application/json', 'Timeout', 5);
        modelInfo = webwrite(service_url, '', options);
        modelNames = modelInfo.model_names;
        modelTimes = modelInfo.model_timestamps;
        fprintf('Available models found:\n')
        for k = 1:length(modelNames)
            fprintf('\t%s (%s)\n', modelNames{k}, modelTimes{k});
        end
        fprintf('\nSet your WhisperSeg parameters in electro_gui accordingly.\n')
    catch ME
        % Request failed
        if strcmp(ME.identifier, 'MATLAB:webservices:UnknownHost')
            errordlg('Whisper seg web service not available at: %s', service_url);
            error('Whisper seg web service not available at: %s\n', service_url);
        else
            % Something else went wrong
            rethrow(ME);
        end
    end
    return
end

if ischar(data) && strcmp(data, 'update')
    % If only one argument - 'list' - is passed, request that the service
    % look for new models and update
    clear segmentTimes segmentTitles
    service_url = sprintf('http://%s:%s/update', host, port);
    fprintf('Requesting that the WhisperSeg service look for new models in its model folder and load them. Host is at %s at port %s...\n\n', host, port)
    try
        options = weboptions('RequestMethod', 'POST', 'MediaType', 'application/json', 'Timeout', 5);
        response = webwrite(service_url, '', options);
        fprintf('Response from service:\n');
        fprintf('\n\n%s\n\n', response);
    catch ME
        % Request failed
        if strcmp(ME.identifier, 'MATLAB:webservices:UnknownHost')
            errordlg('Whisper seg web service not available at: %s', service_url);
            error('Whisper seg web service not available at: %s\n', service_url);
        else
            % Something else went wrong
            rethrow(ME);
        end
    end
    return
end

% Convert numerical parameters from strings to numbers
min_frequency = str2double(min_frequency);
spec_time_step = str2double(spec_time_step);
min_segment_length = str2double(min_segment_length);
tolerance = str2double(tolerance);
eps = str2double(eps);
time_per_frame_for_scoring = str2double(time_per_frame_for_scoring);
num_trials = str2double(num_trials);
switch use_labels
    case 'true'
        use_labels = true;
    case 'false'
        use_labels = false;
    otherwise
        error('Invalid value for parameter use_labels: %s', use_labels)
end

% Construct a full URL from the given host name and port
service_url = sprintf('http://%s:%s/segment/%s', host, port, network_name);

% Convert the audio data to a byte array
dataBytes = typecast(data, 'uint8');
% Convert the byte array to a base64-encoded string
audio_base64_string = matlab.net.base64encode(dataBytes);
% WhisperSeg was trained on data at 32000 Hz, so we'll use that
whisperSegFs = 32000;
% Assemble a request to send to the WhisperSeg web service
requestInfo = struct('audio_file_base64_string', audio_base64_string, ...
              "channel_id", 0, ...
              "sr", whisperSegFs, ...
              "sr_native", fs, ...
              "min_frequency", min_frequency, ...
              "spec_time_step", spec_time_step, ...
              "min_segment_length", min_segment_length, ...
              "tolerance", tolerance, ...
              "eps", eps, ...
              "time_per_frame_for_scoring", time_per_frame_for_scoring, ...
              "num_trials", num_trials, ... 
              "adobe_audition_compatible", false);
% Serialize the request structure into a json string
jsonData = jsonencode(requestInfo);
% Prepare options for our request
options = weboptions('RequestMethod', 'POST', 'MediaType', 'application/json', 'Timeout', 20);
try
    % Attempt to send data to the web service and await a reply
    response = webwrite(service_url, jsonData, options);
    % Reply received! Reformat the results into electro_gui's Nx2 segment
    % time array format
    segmentTimes = round([response.onset, response.offset]*whisperSegFs) + 1;  % + 1 to convert from python's zero-indexing to MATLAB's one-indexing
    if use_labels
        % Use WhisperSeg segment labels
        segmentTitles = response.cluster.';
    end
    if isfield(response, 'message') && ~isempty(response.message) && ~strcmp(response.message, 'Success')
        % If WhisperSeg sent a message, display it in alert and command window
        fprintf('\nMessage from WhisperSeg server... \n\n%s\n\n ...message end\n\n.', response.message)
    end
catch ME
    % Request failed
    if strcmp(ME.identifier, 'MATLAB:webservices:UnknownHost')
        % Either URL is wrong, or the web service is down - warn the user
        errordlg('Whisper seg web service not available at: %s', service_url);
    else
        % Something else went wrong
        rethrow(ME);
    end
    % Return an empty array and move on
    segmentTimes = zeros(0, 2);
end