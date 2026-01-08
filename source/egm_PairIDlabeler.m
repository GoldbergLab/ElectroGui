function obj = egm_PairIDlabeler(obj)
% ElectroGui macro
% Template for creating electro_gui macros
%   Save this as egm_<<macro name>>.m and edit it to do whatever you want
%   Below is some skeleton code that may or may not be useful, feel free to 
%       delete or change it to suit your purposes.

% Get some user input for macro
fileRangeString = ['1:' num2str(electro_gui.getNumFiles(obj.dbase))];
answer = inputdlg( ...
    {'File range to do stuff on'}, ...
     'Macro name', 1, ...
     {fileRangeString});

if isempty(answer)
    % User cancelled
    return
end

filenums = eval(answer{1});

% Loop over selected files and do something
for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    fprintf('Doing something with file #%d (%d of %d)\n', filenum, fileIdx, length(filenums))

    % You can acccess the current state of the loaded dbase like so:
    %1. Get segments
    segTimes = obj.dbase.SegmentTimes{filenum};
    %2. Get Aux sound channel
    auxChan = obj.getAuxiliarySoundSources();
    auxChan = auxChan{1};

    %3. Calculate amplitudes of Sound and Aux vectors
    amp = obj.calculateAmplitude(filenum);
    auxamp = obj.calculateAmplitude(filenum, auxChan);
    %4. Loop over each segment and in that loop compare the amplitude of
    %the two sounds in that segment

    for seg = 1:size(segTimes,1)
        disp('working on segment')
        disp(seg)
        onset = segTimes(seg,1);
        offset = segTimes(seg,2);
        if offset>length(amp)
            ampsegment = amp(onset:end);
            auxampsegment = auxamp(onset:end);
        else
            ampsegment = amp(onset:offset);
            auxampsegment = auxamp(onset:offset);
        end

    %5. Capitalize the segment titles based on the result of that
        if mean(ampsegment) > mean(auxampsegment)
            obj.dbase.SegmentTitles{filenum}{seg} = upper(obj.dbase.SegmentTitles{filenum}{seg});
        end
    end
end

obj.updateAnnotations();
