function [video, label] = egf_deMedianVideo(video,fs,params)
% ElectroGui filter
% De-median frame subtracts off the median frame, either completely or
% partially.

defaultFraction = '1.0';
defaultNames = {'fraction'};
defaultValues = {defaultFraction};

% fraction of de-median operation, from 0 to 1. 0 leaves the video unchanged, 1 completely subtracts the median frame.

label = 'De-median';
if isstr(video) & strcmp(video,'params')
    video.Names = defaultNames;
    video.Values = defaultValues;
    return
end

if ~exist('params', 'var') || isempty(params)
    params.Names = defaultNames;
    params.Values = defaultValues;
end

fraction = str2double(getKeyValuePair('fraction', params.Names, params.Values, defaultFraction));

% Compute median frame
videoD = double(video);
medianImage = fraction *median(double(videoD), 4);
% Remove some or all of the median frame from each video frame
for k = 1:size(video, 4)
    videoD(:, :, :, k) = abs(videoD(:, :, :, k) - medianImage);
end

%videoD = double(video) .* videoD;

% Fit videoD pixel values between 0 and 1
maxVal = max(videoD(:));
minVal = min(videoD(:));
videoD = (videoD - minVal)/(maxVal-minVal);

% Increase contrast
videoD = reshape(imadjust(videoD(:)), size(videoD));

if minVal < maxVal
    video = uint8(256*(1-videoD));
end