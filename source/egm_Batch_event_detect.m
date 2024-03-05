function handles = egm_Batch_event_detect(handles)
% ElectroGui macro
% Batch event detection for faster analysis
% Uses current event detection algorithms
% Only works for segmentation based on sound amplitude

answer = inputdlg({'File range'},'File range',1,{['1:' num2str(handles.TotalFileNumber)]});
if isempty(answer)
    return
end

filenums = eval(answer{1});
x = mean(xlim(handles.axes_Sonogram));
y = mean(ylim(handles.axes_Sonogram));
txt = text(handles.axes_Sonogram, x, y, ...
    'Detecting events... Click to quit.', 'HorizontalAlignment', 'center', ...
    'FontSize', 14, 'Color', 'r', 'BackgroundColor', 'w');
txt.ButtonDownFcn = @(varargin)set(txt, 'Color', 'g');

for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    if all(txt.Color==[0 1 0])
        break
    end

    handles.FileLength(filenum) = 0;
    for axnum = 1:2
        eventSourceIdx = electro_gui('GetChannelAxesEventSourceIdx', handles, axnum);
        if ~isempty(eventSourceIdx)
            handles = electro_gui('DetectEvents', handles, eventSourceIdx, filenum);
        end
    end
    
    txt.String = sprintf('Detected events in file %d (%d/%d). Click to quit.', filenum, fileIdx, length(filenums));
    drawnow;
end

delete(txt);

msgbox(sprintf('Detected events in %d files. Detection complete', fileIdx));

