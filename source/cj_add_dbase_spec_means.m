% script to save a gmm that has been fit to spectral features of the
% accelerometer for the purposes of identifying vocalization bouts

clear
close all

dbase_dir = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs'; %hard code directory 
files = dir([dbase_dir '\*dbase*.mat']);
names = {files.name};


afs = 5000;
afwindowlength=0.025*afs;
foverlap=floor(0.020*afs);
aFE = audioFeatureExtractor("SampleRate",afs,...
    "Window",hamming(afwindowlength,"periodic"),...
    "SpectralDescriptorInput","linearSpectrum",...
    "OverlapLength",foverlap,...
    "mfcc",true, ...
    "mfccDelta",false, ...
    "mfccDeltaDelta",true, ...
    "pitch",false, ...
    "spectralSpread",false,...
    "spectralFlatness",true,...
    "shortTimeEnergy",false,...
    "spectralCrest",false, ...
    "spectralEntropy",true, ...
    "spectralFlux",true, ...
    "spectralKurtosis",true, ...
    "spectralRolloffPoint",false, ...
    "spectralCrest",true, ...
    "spectralSkewness",true, ...
    "spectralSlope",true, ...
    "harmonicRatio",true, ...
    "spectralCentroid",true);

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
    
    allmovfeats = [];
    %downsample to 1000 files
    soundfiles = datasample(soundfiles,500,'replace',false);
    for k = 1:length(soundfiles)
        disp(['File ' num2str(k) ' of ' num2str(length(soundfiles))])
        %S = egl_HC_ad([path '\' soundfiles{k}],1);
        movex = egl_HC_ad([path '\' xfiles{k}],1);
        movey = egl_HC_ad([path '\' yfiles{k}],1);
        movez = egl_HC_ad([path '\' zfiles{k}],1);
        movecom = sqrt(movex.^2+movey.^2+movez.^2);
        movecom = wdenoise(movecom,12,'ThresholdRule','Soft');
        movecom = highpass(movecom,1000,afs,'ImpulseResponse','fir','Steepness',0.5);
        feats = extract(aFE,movecom);
        allmovfeats = [allmovfeats; feats];
        
    end
    %Fit GMM
    %normalize features
    %allmovfeats = normalize(allmovfeats);
    alambda = 1e-3;
    nn = 2;
    agmm = fitgmdist(allmovfeats,nn,'CovarianceType','diagonal','RegularizationValue',alambda);
    dbase.agmm = agmm;
    save([dbase_dir '\' names{i}],'dbase')
    clear dbase
end