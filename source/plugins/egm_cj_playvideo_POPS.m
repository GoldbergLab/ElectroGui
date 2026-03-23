function obj = egm_cj_playvideo_POPS(obj)
    %% electro_gui macro to play a video based on the current view of the sonogram

    % Get the current file number
    fileNum = electro_gui.getCurrentFileNum(obj.settings);
    % Get the current file name
    n = electro_gui.getCurrentFileName(obj.dbase, obj.settings);
    
    % get start and stop time for video
    xl = get(obj.axes_Sonogram,'xlim');
    
    % get birdID & date from file name
    birdID = n(1:4);
    tt = strfind(n,'_');
    date = n(tt(2)+1:strfind(n,'T')-1);
    year = date(1:4);
    month = date(5:6);
    day = date(7:8);
    % build path to video
    basepath = 'Y:\ht452\AAc_analysis';
    birdpath = [basepath '\' birdID '\videos\' month day year];
    if strcmp(birdID, '0010')
         birdpath = [basepath '\' birdID '\videos\' month day year '\Alligned_videos_new'];
         if ~isfolder(birdpath)
            birdpath = [basepath '\' birdID '\videos\' month day year '\Alligned_videos'];
         end 
    end
    fnum = n(tt(1)+2:tt(2)-1);
    hnum = fnum(end-3:end);
%     dnum = str2num(fnum);
%     dnum = num2str(dnum);
    cd(birdpath)
    vid = dir(['*' hnum '*.mp4']);
    if ~isempty(vid)
        vidName = vid.name;
        fullPath = [birdpath '\' vidName];
    else
        error('Video not found')
    end
    
    %video stuff
    % Load audio
    axnum = 1;
    eventPart = 2;

    [snd, fs] = obj.getSound([], fileNum);

    tempVidPath = tempname();
    tempAudPath = tempname();
    tempAudPath = [tempAudPath '.wav'];
    tempVidPath = [tempVidPath '.mp4'];
    disp(tempVidPath)
    disp(tempAudPath)

    % Get the event source index for the specified channel axes
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    if isempty(eventSourceIdx)
        % No event source in the axes
        error('No events detected in the axes %d', axnum);
    end

    spikeAudio = zeros(1,length(snd));
    if chanNum ~= 0
        % Get the event times for the given event source index, event part,
        %   and file number
        eventTimes = obj.dbase.EventTimes{eventSourceIdx}{eventPart, fileNum};
        spikeAudio(eventTimes) = 1;
    end
    
    padsize = 5; % Higher number means lower frequency sound for spikes 
    padKernel = ones(1,2*padsize+1);
    paddedAudio = conv(spikeAudio,padKernel,'same');
    
    audiowrite(tempAudPath,paddedAudio,fs);
    cmd = sprintf('ffmpeg -i "%s" -i "%s" -c:v copy -map 0:v:0 -map 1:a:0 -y "%s"', fullPath, tempAudPath, tempVidPath);
    [~,~] = system(cmd);
    
    % get behavior segments for this file
    fs = obj.fs;
    markerTimes = obj.dbase.MarkerTimes{fileNum}/fs;
    markerTitles = obj.dbase.MarkerTitles{fileNum};
    smarkTimes = cell(size(markerTimes));
    for i = 1:numel(markerTimes)
        seconds = mod(markerTimes(i),60);
        milliseconds = mod(markerTimes(i),1)*1000;
        smarkTimes{i} = sprintf('00:00:%02d,%03d',floor(seconds),round(milliseconds));
    end
    
    if size(markerTimes,1)>0
        for i = 1:size(markerTimes,1)
            switch markerTitles{i}
                case 'h'
                    subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text','Headbob'); %#ok<*AGROW> 
                case 'a'
                    subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text','Allogroom');
                case 'g'
                    subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text','General Move');
                case 'k'
                    subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text','Kissing');
                case 's'
                    subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text','Self Groom');
                case 't'
                    subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text','Tapping');
                case 'w'
                    subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text','Wing Flap');
                otherwise
                    subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text',' ');
            end             
        end
    else
        % create a blank subtitle file if no segments exist
        smarkTimes{1,1} = '00:00:00,000';
        smarkTimes{1,2} = '00:00:00,001';
        subtitles{1} = struct('startTime',smarkTimes{1,1},'endTime',smarkTimes{1,2},'text',' ');
    end
    % specify directory to save temporary subtitle files
    srtPath = 'C:\Users\GLab\Documents\SRTbudgiefiles\subtitle.srt';
    fid = fopen(srtPath,'w');

    for i = 1:numel(subtitles)
        fprintf(fid, '%d\n', i);
        fprintf(fid, '%s --> %s\n', subtitles{i}.startTime, subtitles{i}.endTime);
        fprintf(fid, '%s\n', subtitles{i}.text);
        fprintf(fid, '\n'); % Add an empty line to separate entries
    end
    fclose(fid);
    
    % prepare for video playback
    % runtime = java.lang.Runtime.getRuntime();
    vPath = '"C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"';
    vlcCommand = [vPath, ' "', tempVidPath, '" --start-time=', num2str(xl(1)), ' --stop-time=', num2str(xl(2)), ' --play-and-exit --loop --sub-file=',srtPath,' &'];
    % process = runtime.exec(vlcCommand);
    system(vlcCommand);
    
%     savedir = 'X:\Budgie\Caleb_saved_videos';
%     savename = [birdID '_' date '_' num2str(chanNum) '_' num2str(fileNum) '.mp4'];
%     Closeoption = questdlg('Save video?','Save video','Save','Exit without saving','Exit without saving');
%     if strcmp(Closeoption,'Save')
%         movefile(tempVidPath,fullfile(savedir,savename);
%     else
%         process.destroy();
%     end
    
end