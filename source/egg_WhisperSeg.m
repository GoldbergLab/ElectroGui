function segments = egg_WhisperSeg(data, ~, ~, ~, params)
% ElectroGui segmenter
% This segmenter uses WhisperSeg
% (https://github.com/nianlonggu/WhisperSeg/tree/master) to segment the
% audio data into syllables. It requires a WhisperSeg web service to be
% running either locally or remotely.

% Define default segmenter parameters
defaultParams.Names =  {'WhisperSeg hostname/IP',       'WhisperSeg service port',  'Mininum frequency (Hz)',   'Spectrogram time step (s)',    'Minimum segment length (s)',   'eps',  'Number of trials'};
defaultParams.Values = {'goldbergbk.nbb.cornell.edu',   '8050',                     '0',                        '0.0025',                       '0.01',                         '0.02', '3'};

% Check if the user passed in the string "params" instead of audio data
if ischar(data) && strcmp(data,'params')
    % Return the default parameters
    segments = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end

% Extract the parameters chosen
[host, port, min_frequency, spec_time_step, min_segment_length, eps, num_trials] = params.Values{:};

% Convert numerical parameters from strings to numbers
min_frequency = str2double(min_frequency);
spec_time_step = str2double(spec_time_step);
min_segment_length = str2double(min_segment_length);
eps = str2double(eps);
num_trials = str2double(num_trials);

% Construct a full URL from the given host name and port
service_url = sprintf('http://%s:%s/segment', host, port);

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
              "min_frequency", min_frequency, ...
              "spec_time_step", spec_time_step, ...
              "min_segment_length", min_segment_length, ...
              "eps", eps, ...
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
    segments = round([response.onset, response.offset]*whisperSegFs) + 1;  % + 1 to convert from python's zero-indexing to MATLAB's one-indexing
catch ME
    % Request failed
    if strcmp(ME.identifier, 'MATLAB:webservices:UnknownHost')
        % Either URL is wrong, or the web service is down - warn the user
        errordlg('Web service not available: %s', service_url);
    else
        % Something else went wrong
        rethrow(ME);
    end
    % Return an empty array and move on
    segments = zeros(0, 2);
end