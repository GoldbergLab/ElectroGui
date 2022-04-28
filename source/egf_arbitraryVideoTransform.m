function [video, label] = egf_arbitraryVideoTransform(video,fs,params)
% ElectroGui filter
% Apply an arbitrary transform to the video. Input parameter "transform"
% should be a char array representing a valid MATLAB expression that uses
% the variable 'video', which is a uint8 4-D array of size HxWx3xN, and
% evaluates to another 4D uint8 array.

defaultTransform = 'uint8(repmat(mean(video, 3), [1, 1, 3, 1]))';
defaultNames = {'transform'};
defaultValues = {defaultTransform};

% fraction of de-median operation, from 0 to 1. 0 leaves the video unchanged, 1 completely subtracts the median frame.

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

video = eval(getKeyValuePair('transform', params.Names, params.Values));