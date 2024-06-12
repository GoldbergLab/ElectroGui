function egm_Label_similar_syllables(obj)
% ElectroGui macro
% Export snippets that match criteria

numFiles = electro_gui.getNumFiles(obj.dbase);

fileRangeString = ['1:' num2str(numFiles)];

inputs = getInputs('Parameters for auto-labeling similar syllables:', ...
    {'File range to search', ...
     'Syllable label', ...
     'Syllable minimum length (ms)', ...
     'Syllable maximum length (ms)', ...
     'Power band minimum frequency (Hz)', ...
     'Power band maximum frequency (Hz)', ...
     'Minimum fraction of power in band (0 - 1)', ...
     'Maximum fraction of power in band (0 - 1)'}, ...
     {fileRangeString, ...
      'X', ...
      '10', ...
      '80', ...
      '2000', ...
      '3000', ...
      '0.3', ...
      '0.5'}, ...
      {'Which files should we search for syllables in - specify with a MATLAB expression that evaluates to a list of file numbers', ...
      'What should matching syllables be labeled?', ...
      'Minimum syllable length to label', ...
      'Maximum syllable length to label', ...
      'Lower edge of frequency band to check', ...
      'Upper edge of frequency band to check', ...
      'Minimum amount of power in the specified frequency band, as a fraction of the total power during the syllable', ...
      'Maximum amount of power in the specified frequency band, as a fraction of the total power during the syllable)', ...
      });

if isempty(inputs)
    return
end

filenums = eval(inputs{1});
label = inputs{2};
minLength = str2double(inputs{3})/1000;
maxLength = str2double(inputs{4})/1000;
minFreq = str2double(inputs{5});
maxFreq = str2double(inputs{6});
minFrac = str2double(inputs{7});
maxFrac = str2double(inputs{8});

if ~isrow(filenums)
    filenums = transpose(filenums);
end

if ~isrow(filenums) || ~isnumeric(filenums)
    filenums
    error('File nums must be a 1D vector of file numbers');
end

% Make an invisible figure to plot spectrograms on. It's kind of a hack,
% but oh well. Seemed better than messing with or duplicating the sonogram plugins.
f = figure('Visible','off');
ax = copyobj(obj.axes_Sonogram, f);

% Determine current spectrogram algorithm
for c = 1:length(obj.menu_Algorithm)
    if obj.menu_Algorithm(c).Checked
        alg = obj.menu_Algorithm(c).Label;
        break;
    end
end

flim = [minFreq, maxFreq];

sound = [];

progressBar = waitbar(0, 'Labelling similar syllables...', 'WindowStyle', 'modal');
loop = 0;

numFound = 0;

% Loop over filenames
for filenum = filenums
    loop = loop + 1;
    waitbar(filenum/length(filenums), progressBar, sprintf('Labelling %d of %d...', filenum, length(filenums)));
    numSegments = length(obj.dbase.SegmentTitles{filenum});
    for segmentIdx = 1:numSegments
        tlim = obj.dbase.SegmentTimes{filenum}(segmentIdx, :);
        [~, fs] = obj.eg_GetSamplingInfo(filenum);
        duration = (diff(tlim) / fs);

        if minLength < duration && duration < maxLength
            % Syllable meets duration requirements - check 

            if isempty(sound)
                % Only load sound if we're going to use it
                [sound, fs] = obj.getSound([], filenum);
                [~, ~, sonogramHandle] = ...
                    electro_gui.eg_runPlugin(obj.plugins.spectrums, alg, ...
                        ax, sound, fs, obj.settings.SonogramParams);
            end

            % Find spectrogram power in that syllable both within the
            % specified frequency band and for the whole spectrum
            [totalBandPower, totalPower] = electro_gui.CalculateSpectrogramPower(sonogramHandle, ax, tlim, flim);

            % Compute band power as a fraction of total power
            bandPowerFrac = totalBandPower/totalPower;
            if minFrac < bandPowerFrac && bandPowerFrac < maxFrac
                % This meets the requirements! Rename it.
                obj.dbase.SegmentTitles{filenum}{segmentIdx} = label;
                numFound = numFound + 1;
            end
        end

    end

    % Clear sound
    sound = [];
end

close(progressBar);
msgbox(sprintf('Found and labeled %d similar syllables.', numFound), 'modal');

% Delete the invisible figure
delete(f);