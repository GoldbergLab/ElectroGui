function [video, label] = egf_motionExtractVideo(video,fs,params)
% ElectroGui filter
% Motion detect video

label = 'Motion';
if isstr(video) & strcmp(video,'params')
    video.Names = {};
    video.Values = {};
    return
end

% if ~exist('params', 'var') || isempty(params)
%     params.intensity = 1.0;   % Intensity of de-median operation, from 0 to 1. 0 leaves the video unchanged, 1 completely subtracts the median frame.
% end

diffKernel = permute([-1, 1], [4, 3, 2, 1]);

motion = abs(convn(squeeze(mean(video, 3)), diffKernel, 'same'));
meanMotion = mean(motion(:));
stdevMotion = std(motion(:));

motion = (motion - (meanMotion - stdevMotion)) / (2*stdevMotion);
motion(motion < 0) = 0;
motion(motion > 1) = 1;
motion = motion .* motion;
motion = cat(3, motion, motion, motion);
video = uint8(double(video) .* motion);