function [video, label] = egf_cropVideo(video,fs,params)
% ElectroGui filter
% Crop thumbnails

defaultNames = {'x1', 'x2', 'y1', 'y2'};
defaultValues = arrayfun(@num2str, [1, NaN, 1, NaN], 'UniformOutput', false);

label = 'Cropped Video';
if isstr(video) & strcmp(video,'params')
    video.Names = defaultNames;
    video.Values = defaultValues;
    return
end

videoWidth = size(video, 2);
videoHeight = size(video, 1);


if ~exist('params', 'var') || isempty(params)
    params.Names = defaultNames;
    params.Values = defaultValues;
end

x1 = max(1, round(str2double(getKeyValuePair('x1', params.Names, params.Values))));
x2 = min(videoWidth, round(str2double(getKeyValuePair('x2', params.Names, params.Values))));
y1 = max(1, round(str2double(getKeyValuePair('y1', params.Names, params.Values))));
y2 = min(videoHeight, round(str2double(getKeyValuePair('y2', params.Names, params.Values))));

if isnan(x2)
    x2 = videoWidth;
end
if isnan(y2)
    y2 = videoHeight;
end

video = video(y1:y2, x1:x2, :, :);