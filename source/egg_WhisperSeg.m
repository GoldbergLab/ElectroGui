function segments = egg_WhisperSeg(data, ~, ~, ~, params)
% ElectroGui segmenter

defaultParams.Names =  {'WhisperSeg hostname/IP',       'WhisperSeg service port',  'Mininum frequency (Hz)',   'Spectrogram time step (s)',    'Minimum segment length (s)',   'eps',  'Number of trials'};
defaultParams.Values = {'goldbergbk.nbb.cornell.edu',   '8050',                     '0',                        '0.0025',                       '0.01',                         '0.02', '3'};

if ischar(data) && strcmp(data,'params')
    segments = defaultParams;
    return
end

if ~exist('params', 'var')
    params = defaultParams;
end

[host, port, min_frequency, spec_time_step, min_segment_length, eps, num_trials] = params.Values{:};

min_frequency = str2double(min_frequency);
spec_time_step = str2double(spec_time_step);
min_segment_length = str2double(min_segment_length);
eps = str2double(eps);
num_trials = str2double(num_trials);

service_url = sprintf('http://%s:%s/segment', host, port);

dataBytes = typecast(data, 'uint8');
audio_base64_string = matlab.net.base64encode(dataBytes);
whisperSegFs = 32000;
requestInfo = struct('audio_file_base64_string', audio_base64_string, ...
              "channel_id", 0, ...
              "sr", whisperSegFs, ...
              "min_frequency", min_frequency, ...
              "spec_time_step", spec_time_step, ...
              "min_segment_length", min_segment_length, ...
              "eps", eps, ...
              "num_trials", num_trials, ... 
              "adobe_audition_compatible", false);
jsonData = jsonencode(requestInfo);
options = weboptions('RequestMethod', 'POST', 'MediaType', 'application/json');
response = webwrite(service_url, jsonData, options);
segments = round([response.onset, response.offset]*whisperSegFs);
