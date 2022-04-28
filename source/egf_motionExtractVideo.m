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

% diffKernel = permute([-1, 1], [4, 3, 2, 1]);
% 
% motion = abs(convn(mean(video, 3), diffKernel, 'same'));

videoD = double(mean(video, 3));

motion = padarray(videoD(:, :, :, 2:end) - videoD(:, :, :, 1:end-1), [0, 0, 0, 1], 'post');

% meanMotion = mean(motion(:));
% stdevMotion = std(motion(:));
% 
% motion = (motion - (meanMotion - stdevMotion)) / (2*stdevMotion);
% motion(motion < 0) = 0;
% motion(motion > 1) = 1;
maxMotion = max(motion(:));
minMotion = min(motion(:));
motion = (motion - minMotion) / (maxMotion - minMotion);
% motion = motion .* motion;
motion = cat(3, motion, motion, motion);
video = uint8(256 * motion); %videoD .* motion);