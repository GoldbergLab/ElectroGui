function dbase = cj_add_Han_segments(dbase)
% get birdID & date from file name from first file in dbase path
soundfiles = {dbase.SoundFiles.name};
n = soundfiles{1};
birdID = n(1:4);
tt = strfind(n,'_');
date = n(tt(2)+1:strfind(n,'T')-1);
year = date(1:4);
month = date(5:6);
day = date(7:8);

% verify date with user
answer = questdlg(['Verify date: ' sprintf('\n') 'Year: ' year sprintf('\n') ' Month: ' month sprintf('\n') ' Day: ' day],...
    'Sup player',...
    'Continue','Cancel','Cancel');
switch answer
    case 'Cancel'
        return
    case 'Continue'
        display('lets do this big dog')        
end

%get text file numbers
d_num = zeros(length(soundfiles),1);
for i = 1:length(soundfiles)
    ind = strfind(soundfiles{i},'_');
    d_num(i) = str2num(soundfiles{i}(ind(1)+2:ind(2)-1));
end

% build path to video
basepath = 'Y:\ht452\AAc_analysis\';
birdpath = [basepath birdID '\segmentations\'];
datepath = [birdpath month day year];

% define gestures
gestures = {'allogrooming', 'general_movement', 'headbob','kissing',...
    'selfgrooming','tapping','wingflap'};
for i = 1:length(gestures)
    fullpath = [datepath '\' gestures{i}];
    if isdir(fullpath) && exist([fullpath '\' 'segmentations_cleaned.mat'],'file')
        segs = load([fullpath '\' 'segmentations_cleaned.mat']);
        name = fieldnames(segs);
        segs = segs.(name{1});
    else
        continue
    end
    % add struct stuff to dbase
    if i==3 % get headbob bouts
        onsets = segs.bout_onsets;
        offsets = segs.bout_offsets;
        i_onsets = segs.onsets;
        i_offsets = segs.offsets;
        dbase.(gestures{i}).boutTimes = cell(1,length(soundfiles));
        dbase.(gestures{i}).indbobTimes = cell(1,length(soundfiles));
    else
        onsets = segs.onsets;
        offsets = segs.offsets;
        dbase.(gestures{i}).Times = cell(1,length(soundfiles));
        dbase.(gestures{i}).Times = cell(1,length(soundfiles));
    end
    vidnums = segs.vid_num;
    for j = 1:length(vidnums)
        % match video file number to sound file
        filenum = find(d_num==vidnums(j));
        if ~isempty(onsets{1,j})
            % get current number of markers for this file so as to add on
            numMarks = size(dbase.MarkerTimes{1,filenum},1);
            % assign gestures a marker and populate dbase
            dbase.MarkerTimes{1,filenum}(numMarks+1:length(onsets{1,j})+numMarks,1) = onsets{1,j}';
            dbase.MarkerTimes{1,filenum}(numMarks+1:length(onsets{1,j})+numMarks,2) = offsets{1,j}';
            for r = 1:length(onsets{1,j})
                dbase.MarkerTitles{1,filenum}{1,numMarks+r} = gestures{i}(1);
            end
            % populate is selected field
            dbase.MarkerIsSelected{1,filenum} = ones(1,length(onsets{1,j})+numMarks);
            if i ==3
                dbase.(gestures{i}).boutTimes{1,filenum}(:,1) = onsets{1,j}';
                dbase.(gestures{i}).boutTimes{1,filenum}(:,2) = offsets{1,j}';
                dbase.(gestures{i}).indbobTimes{1,filenum}(:,1) = i_onsets{1,j}';
                dbase.(gestures{i}).indbobTimes{1,filenum}(:,2) = i_offsets{1,j}';     
            else
                dbase.(gestures{i}).Times{1,filenum}(:,1) = onsets{1,j}';
                dbase.(gestures{i}).Times{1,filenum}(:,2) = offsets{1,j}';
            end
            % populate boolean
            dbase.Properties.Values{1,filenum}{1,i} = 1;
        end
    end
end


