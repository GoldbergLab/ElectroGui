function handles = egm_Batch_event_detect(handles)
% ElectroGui macro
% Batch event detection for faster analysis
% Uses current event detection algorithms
% Only works for segmentation based on sound amplitude

answer = inputdlg({'File range'},'File range',1,{['1:' num2str(handles.TotalFileNumber)]});
if isempty(answer)
    return
end

fileNums = eval(answer{1});
for c = 1:length(handles.menu_Segmenter)
    if strcmp(get(handles.menu_Segmenter(c),'checked'),'on')
        alg = get(handles.menu_Segmenter(c),'label');
    end
end

txt = text(handles.axes_Sonogram, mean(xlim), mean(ylim), ...
    'Detecting events... Click to quit.', 'HorizontalAlignment', 'center', ...
    'FontSize', 14, 'Color', 'r', 'BackgroundColor', 'w');
txt.ButtonDownFcn = @(varargin)set(txt, 'Color', 'g');

for fileIdx = 1:length(fileNums)
    fileNum = fileNums(fileIdx);
    if all(txt.Color==[0 1 0])
        break
    end

    handles.FileLength(fileNum) = 0;
    for axnum = 1:2
        eventSourceIdx = electro_gui('GetChannelAxesEventSourceIdx', handles, axnum);
        if ~isempty(eventSourceIdx)
            handles = electro_gui('DetectEvents', handles, eventSourceIdx, fileNum);
        end
    end
    
    txt.String = sprintf('Detected events in file %d (%d/%d). Click to quit.', fileNum, fileIdx, length(fileNums));
    drawnow;
end

delete(txt);

msgbox(['Detected events in ' num2str(fileIdx-1) ' files.'],'Detection complete');

