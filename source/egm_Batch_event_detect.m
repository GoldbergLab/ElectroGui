function egm_Batch_event_detect(obj)
% ElectroGui macro
% Batch event detection for faster analysis
% Uses current event detection algorithms
% Only works for segmentation based on sound amplitude
arguments
    obj electro_gui
end


numFiles = obj.getNumFiles(obj.dbase);

answer = inputdlg({'File range'},'File range',1,{['1:' num2str(numFiles)]});
if isempty(answer)
    return
end

filenums = eval(answer{1});
x = mean(xlim(obj.axes_Sonogram));
y = mean(ylim(obj.axes_Sonogram));

progressBar = waitbar(0, obj.figure_Main, 'Detecting events...');

for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    if all(txt.Color==[0 1 0])
        break
    end

    obj.dbase.FileLength(filenum) = 0;
    for axnum = 1:2
        eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
        if ~isempty(eventSourceIdx)
            obj.DetectEvents(eventSourceIdx, filenum);
        end
    end

    if ~isvalid(progressBar)
        msgbar('Batch event detect stopped');
        return
    end

    waitbar(filenum/length(filenums), progressBar);

    drawnow;
end

msgbox(sprintf('Detected events in %d files. Detection complete', fileIdx));