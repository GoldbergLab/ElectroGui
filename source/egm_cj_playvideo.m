function handles = egm_cj_playvideo(handles)
    %% electro_gui macro to play a video based on the current view of the sonogram
    dbase = handles.dbase;
    fileNum = getCurrentFileNum(handles);
    n = getCurrentFileName(handles);
    
    % get start and stop time for video
    xl = get(handles.axes_Sonogram,'xlim');
    
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
    dnum = str2num(n(tt(1)+2:tt(2)-1));
    dnum = num2str(dnum);
    cd(birdpath)
    vidName = dir(['*' dnum '*.mp4']);
    vidName = vidName.name;
    fullPath = [birdpath '\' vidName];
    if ~exist(fullPath,'file')
        error('Video does not exist');
    end
    
    % get behavior segments for this file
    fs = handles.fs;
    markerTimes = handles.MarkerTimes{fileNum}/fs;
    markerTitles = handles.MarkerTitles{fileNum};
    smarkTimes = cell(size(markerTimes));
    for i = 1:numel(markerTimes)
        seconds = mod(markerTimes(i),60);
        milliseconds = mod(markerTimes(i),1)*1000;
        smarkTimes{i} = sprintf('00:00:%02d,%03d',floor(seconds),round(milliseconds));
    end
    for i = 1:size(markerTimes,1)
        switch markerTitles{i}
            case 'h'
                subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text','Headbob');
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
    
    %prepare for video playback
    vPath = '"C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"';
    vlcCommand = [vPath, ' "', fullPath, '" --start-time=', num2str(xl(1)), ' --stop-time=', num2str(xl(2)), ' --play-and-exit --loop --sub-file=',srtPath];
    system(vlcCommand);
    
end


%define functions to retrieve filenum and name
function currentFileNum = getCurrentFileNum(handles)
currentFileNum = str2double(get(handles.edit_FileNumber, 'string'));
end
function currentFileName = getCurrentFileName(handles)
currentFileNum = getCurrentFileNum(handles);
currentFileName = handles.sound_files(currentFileNum).name;
end