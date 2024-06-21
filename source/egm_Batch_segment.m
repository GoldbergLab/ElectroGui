function egm_Batch_segment(obj)
% ElectroGui macro
% Batch syllable segmentation for faster analysis
% Uses current segmentation algorithm and parameters
% Only works for segmentation based on sound amplitude
    arguments
        obj electro_gui
    end

    numFiles = electro_gui.getNumFiles(obj.dbase);
    
    answer = inputdlg({'File range'}, 'File range', 1, {sprintf('1:%d', numFiles)});
    if isempty(answer)
        return
    end
    
    filenums = eval(answer{1});
    if ~isnumeric(filenums) || ~all(filenums == floor(filenums)) || min(filenums) < 1 || max(filenums) > numFiles
        errordlg(sprintf('Invalid file range: %s', answer{1}));
        return;
    end
    for filenum = 1:length(obj.menu_Segmenter)
        if obj.menu_Segmenter(filenum).Checked
            segmenterAlgorithmName = obj.menu_Segmenter(filenum).Label;
        end
    end
    
    progressBar = waitbar(0, 'Segmenting...');
    for fileIdx = 1:length(filenums)
        waitbar(fileIdx/length(filenums), progressBar);
        %displayProgress('Segmenting file %d of %d, fileIdx', length(filenums), round(length(filenums)/10), true);
        filenum = filenums(fileIdx);
    
        sound = obj.getSound([], filenum);
        [amp, fs] = obj.calculateAmplitude(filenum);
    
        if obj.menu_AutoThreshold.Checked
            obj.dbase.SegmentThresholds(filenum) = electro_gui.eg_AutoThreshold(amp);
        else
            obj.dbase.SegmentThresholds(filenum) = obj.settings.CurrentThreshold;
        end
        curr = obj.dbase.SegmentThresholds(filenum);
        
        obj.dbase.SegmentTimes{filenum} = electro_gui.eg_runPlugin(obj.plugins.segmenters, segmenterAlgorithmName, sound, amp, fs, curr, obj.settings.SegmenterParams);
        obj.dbase.SegmentTitles{filenum} = cell(1,size(obj.dbase.SegmentTimes{filenum},1));
        obj.dbase.SegmentIsSelected{filenum} = true(1,size(obj.dbase.SegmentTimes{filenum},1));
    
    end
    close(progressBar);
    msgbox(sprintf('Segmented %d files. Segmentation complete', fileIdx));

end