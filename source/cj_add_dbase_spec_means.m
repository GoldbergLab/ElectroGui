% script to save mean spectrogram info about acc and sound to dbases

clear
close all

dbase_dir = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs'; %hard code directory 
files = dir([dbase_dir '\*dbase*.mat']);
names = {files.name};

specylim = [0 8000];
aspecylim = [0 2500];
for i = 49:length(names)
    dbase = load([dbase_dir '\' names{i}]);
    dbase = dbase.dbase;
    path = dbase.PathName;
    chan = names{i}(strfind(names{1},'chan')+4:strfind(names{1},'chan')+5);
    chan = strrep(chan,'_','');
    birdID = names{i}(6:9); %hard coded, trusts stereotyped name format
    lc = strfind(names{i},'_');
    date = names{i}(lc(1)+1:lc(2)-1);
    
    fs = dbase.Fs;
    % Define the high pass filter cutoff frequency for SOUND
    Fcutoff = [400  8000]; 
    % Normalize the cutoff frequency
    Wcutoff = Fcutoff / (fs/2);
    % Design the filter using fir1
    N = 50; % Order of the filter
    b = fir1(N, Wcutoff);

    soundfiles = {dbase.SoundFiles.name};
    soundfiles = natsort(soundfiles);
    zfiles = dir([path '\*chan18.*']);
    xfiles = dir([path '\*chan19.*']);
    yfiles = dir([path '\*chan20.*']);
    zfiles = {zfiles.name};
    zfiles = natsort(zfiles);
    xfiles = {xfiles.name};
    xfiles = natsort(xfiles);
    yfiles = {yfiles.name};
    yfiles = natsort(yfiles);

    allpmeans = [];
    allsmeans = [];

    %downsample to 1000 files
    soundfiles = datasample(soundfiles,100,'replace',false);
    for k = 1:length(soundfiles)
        disp(['File ' num2str(k) ' of ' num2str(length(soundfiles))])
        S = egl_HC_ad([path '\' soundfiles{k}],1);
        movex = egl_HC_ad([path '\' xfiles{k}],1);
        movey = egl_HC_ad([path '\' yfiles{k}],1);
        movez = egl_HC_ad([path '\' zfiles{k}],1);
        movecom = sqrt(movex.^2+movey.^2+movez.^2);
        movecom = highpass(movecom,250,5000);
        
        %move spec
        [SS,F,t] = specgram(movecom, 512/2, 5000, 256/2,floor(0.75*256/2));
        ndx = find((F>=specylim(1)) & (F<=specylim(2)));
        %p= 2*log(abs(SS(ndx,:))+eps)+20;
        p = abs(SS);
        thispmean = mean(p,2);
        allpmeans = [allpmeans thispmean];

        %sound spec
        [SS,F,t] = specgram(S, 512, fs, 256,floor(0.75*256));
        ndx = find((F>=specylim(1)) & (F<=specylim(2)));
        p= 2*log(abs(SS(ndx,:))+eps)+20;
        thissmean = mean(p,2);
        allsmeans = [allsmeans thissmean];
    end
    dbase.means.sound_spec = mean(allsmeans,2);
    dbase.means.move_spec = mean(allpmeans,2);
    save([dbase_dir '\' names{i}],'dbase')
    clear dbase
end