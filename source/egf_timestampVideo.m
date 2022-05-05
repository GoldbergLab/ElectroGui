function [video, label] = egf_timestampVideo(video,fs,params)
% ElectroGui filter
% Add a time or frame stamp to corner of video

defaultTimeStamp = 'true';
defaultFrameStamp = 'true';
timeStampKey = 'Include time stamp';
frameStampKey = 'Include frame stamp';
defaultNames = {frameStampKey, timeStampKey};
defaultValues = {defaultFrameStamp, defaultTimeStamp};

label = 'User-defined video transform';
if isstr(video) & strcmp(video,'params')
    video.Names = defaultNames;
    video.Values = defaultValues;
    return
end

if ~exist('params', 'var') || isempty(params)
    params.Names = defaultNames;
    params.Values = defaultValues;
end

timeStamp = str2num(getKeyValuePair(timeStampKey, params.Names, params.Values));
frameStamp = str2num(getKeyValuePair(frameStampKey, params.Names, params.Values));

if timeStamp || frameStamp
    video = flip(video, 1);

    textHeight = 21; % Height of text in pixels
    for k = 1:size(video, 4)
        text = {};
        position = [];
        y = 0;
        if frameStamp
            text{end+1} = num2str(k);
            position = [position; [0, y]];
            y = y + textHeight;
        end
        if timeStamp
            text{end+1} = sprintf('%.2f', k/fs);
            position = [position; [0, y]];
            y = y + textHeight;
        end
        video(:, :, :, k) = insertText(video(:, :, :, k), position, text, 'AnchorPoint', 'LeftTop');
    end

    video = flip(video, 1);
end