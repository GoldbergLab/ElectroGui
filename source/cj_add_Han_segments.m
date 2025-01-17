function dbase = cj_add_Han_segments(dbase,bWashBools)
    %% this boi adds Han's behavioral segmentations to a dbase. Importantly, it clears the dbase of existing segments and markers
    % get birdID & date from file name from first file in dbase path
    % if bWash == 1, gets rid of almost all extra fields that were
    % previously added by RC or ACR
    % I am also adding a section that will look at all the sound files and
    % make a guess about it containing warble and populate a boolean 
    soundfiles = {dbase.SoundFiles.name};
    n = soundfiles{1};
    birdID = n(1:4);
    tt = strfind(n,'_');
    date = n(tt(2)+1:strfind(n,'T')-1);
    year = date(1:4);
    month = date(5:6);
    day = date(7:8);
    
    %get text file numbers
    d_num = zeros(length(soundfiles),1);
    for i = 1:length(soundfiles)
        ind = strfind(soundfiles{i},'_');
        d_num(i) = str2num(soundfiles{i}(ind(1)+2:ind(2)-1));
    end

    % replace B with X for pathname (this is hardcoded personal preference)
    if dbase.PathName(1) == 'B'
        dbase.PathName(1) = 'X';
    end
    
    % build path to video
    basepath = 'Y:\ht452\AAc_analysis\';
    birdpath = [basepath birdID '\segmentations\'];
    datepath = [birdpath month day year];
    
    % define gestures
    gestures = {'allogrooming', 'general_movement', 'headbob','kissing',...
        'selfgrooming','tapping','wingflap','containsWarb','containsCall','loud','bBehav'};
    
    if bWashBools == 1
        [dbase.Properties.Names{:}] = deal(gestures);
        dealboi = cell(1,length(gestures));
        [dealboi{:}] = deal(0);
        [dbase.Properties.Values{:}] = deal(dealboi);
        dealboi = zeros(1,length(gestures));
        dealboi(:) = deal(2);
        [dbase.Properties.Types{:}] = deal(dealboi);
    end

    %Clear out old marker times
    dbase.MarkerTimes = cell(1,length(dbase.MarkerTimes));
    dbase.MarkerTitles = cell(1,length(dbase.MarkerTitles));
    dbase.MarkerIsSelected = cell(1,length(dbase.MarkerIsSelected));

    
    for i = 1:length(gestures)-4 %-4 cuz don't want to do containsWarb or containsCall or loud or bBehav
        fullpath = [datepath '\' gestures{i}];
        if isdir(fullpath) && exist([fullpath '\' 'segmentations_cleaned.mat'],'file')
            segs = load([fullpath '\' 'segmentations_cleaned.mat']);
            name = fieldnames(segs);
            segs = segs.(name{1});
        elseif exist([fullpath '\' 'segmentations.mat'],'file')
            segs = load([fullpath '\' 'segmentations.mat']);
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
                % change any 0th sample onsets to 1
                onsets{1,j}(onsets{1,j}==0) = 1;
                % assign gestures a marker and populate dbase 
                dbase.MarkerTimes{1,filenum}(numMarks+1:length(onsets{1,j})+numMarks,1) = round(onsets{1,j}');
                dbase.MarkerTimes{1,filenum}(numMarks+1:length(onsets{1,j})+numMarks,2) = round(offsets{1,j}');
                for r = 1:length(onsets{1,j})
                    dbase.MarkerTitles{1,filenum}{1,numMarks+r} = gestures{i}(1);
                end
                % populate isSelected field
                dbase.MarkerIsSelected{1,filenum} = ones(1,length(onsets{1,j})+numMarks);
                % get extra headbob data
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
    
    % Get vocalization segments and additional bools for vocalizer and warble
    % and such, also get rid of those stupid mf vocalization segments that
    % exist already
    
    % clear out any previous segs and bools about selection and shit 
    dbase.SegmentIsOtherBird = {}; %some old stuff from RC code
    dbase.SegmentTimes = cell(1,length(dbase.SegmentTimes));
    dbase.SegmentTitles = cell(1,length(dbase.SegmentTitles));
    dbase.SegmentIsSelected = cell(1,length(dbase.SegmentIsSelected));
    vocsegspath = [datepath '\vocalization\segmentations_cleaned.mat'];
    if  exist(vocsegspath,'file')
        vsegs = load(vocsegspath);
        name = fieldnames(vsegs);
        vsegs = vsegs.(name{1});
        vidnums = vsegs.vid_num;
        % add this info to the dbase
        dbase.vsegs = vsegs;
        for k = 1:length(vidnums)
            if iscell(vidnums)
                vidnums = cell2mat(vidnums);
            end
            filenum = find(d_num==vidnums(k));
            if ~isfield(vsegs,'call_onsets')
                vsegs.call_onsets = vsegs.onsets;
                vsegs.call_offsets = vsegs.offsets;
            end
            if ~isfield(vsegs,'call_identity')
                vsegs.call_identity = vsegs.identity;
            end
            if length(vsegs.call_onsets{k}) ~= length(vsegs.call_offsets{k})
                disp('MISMATCH')
                mismatch = 1;
            else
                mismatch = 0;
                numcalls = length(vsegs.call_onsets{k});
            end
            % add call times to dbase
            dbase.SegmentTimes{1,filenum}(:,1) = round(vsegs.call_onsets{k});
            dbase.SegmentTimes{1,filenum}(:,2) = round(vsegs.call_offsets{k});
            dbase.SegmentIsSelected{1,filenum} = vsegs.call_identity{k}';
            % populate containscall bool
            if numcalls>0
                dbase.Properties.Values{1,filenum}{1,length(gestures)-2} = 1;%MINUS two of length of gestures(hard coded index)
               for w = 1:numcalls
                    if vsegs.call_identity{k}(w) == 1
                        dbase.SegmentTitles{1,filenum}{1,w} = 'C';
                    else
                        dbase.SegmentTitles{1,filenum}{1,w} = 'O';
                    end
               end
            end
            % add title of 'C' for call and 'O' for other bird call

        end
        % add warb bool
        if isfield(vsegs,'warble_boolean')
            warbfils = find(vsegs.warble_boolean);
        else
            warbfils = [];
        end
        for r = warbfils'
            dbase.Properties.Values{1,r}{1,length(gestures)-3} = 1;%MINUS three hard coded index
        end
    end
    % here we will loop through all sound files and measure rms % I don't
    % actually like this that much - cj
%     for i = 1:length(soundfiles)
%         disp([num2str(i) ' of ' num2str(length(soundfiles))])
%         file = [dbase.PathName '\' soundfiles{i}];
%         if isfile(file)
%             dat = egl_HC_ad(file,1);
%             cdat = dat-mean(dat);
%             e_dat(i) = rms(cdat);
%         else
%             e_dat(i) = nan;
%         end  
%     end
%     louds = find(e_dat>prctile(e_dat(~isnan(e_dat)),87));
%     for i = 1:length(dbase.Properties.Values)
%         if any(louds==i)
%             dbase.Properties.Values{1,i}{1,length(gestures)-1} = 1;
%         end
%     end
    % here going to make new boolean that is 'bBehav'
    for i = 1:length(soundfiles)
        if any(concatenate(dbase.Properties.Values{i}))
            dbase.Properties.Values{1,i}{1,length(gestures)} = 1;
        end
    end
    % save new dbase with added info to caleb's folder
    savedir = 'X:\Budgie\0010_0572\dbases\caleb_dbases';
    savename = ['dbase' birdID '_' date '_segs.mat'];
    save([savedir '\' savename],'dbase')
     
end
