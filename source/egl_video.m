function [data, fs, dateandtime, label, props] = egl_video(filename, loaddata, loadInfo)
% Brian Kardon
% ElectroGui file loader
% Reads video files

if ~exist('loadInfo', 'var') || isempty(loadInfo)
    loadInfo = false;
end

if loaddata
    data = loadVideoData(filename, 0);
    video = VideoReader(filename);
    fs = get(video, 'FrameRate');
    dateandtime = [];
    label = 'Video';
else
    data.isVideo = 1;
    if loadInfo
        video = VideoReader(filename);
        fs = get(video, 'FrameRate');
        dateandtime = [];
        label = 'Video';
    else
        fs = [];
        dateandtime = [];
        label = [];
    end
end

props.Names = {};
props.Values = {};
props.Types = [];