function dbase = cj_add_Han_segments(dbase)
% get birdID & date from file name from first file in dbase path
dpath = dbase.PathName;

birdID = n(1:4);
tt = strfind(n,'_');
date = n(tt(2)+1:strfind(n,'T')-1);
year = date(1:4);
month = date(5:6);
day = date(7:8);

% % verify date with user
% answer = questdlg(['Verify date: ' sprintf('\n') 'Year: ' year sprintf('\n') ' Month: ' month sprintf('\n') ' Day: ' day],...
%     'Sup player',...
%     'Continue','Cancel','Cancel');
% switch answer
%     case 'Cancel'
%         return
%     case 'Continue'
%         display('lets do this big dog')        
% end


% build path to video
basepath = 'Y:\ht452\AAc_analysis\';
birdpath = [basepath birdID '\segmentations\'];
datepath = [birdpath month day year];

%first gestures
gestures = {'allogrooming' 'general_movement' 'headbob' 'kissing' 'selfgrooming' 'tapping' 'wingflap'};

available_segs = dir(datepath);
available_segs = {available_segs.name};

for i = 1:length(gestures)
    fullpath = [datepath '\' gestures{i}];
    if isdir(fullpath) && exist([fullpath '\' 'segmentations_cleaned.mat'])
        segs = load([fullpath '\' 'segmentations_cleaned.mat']);
    else
        continue
    end
    dbase.Properties.Values{1}{1} = 1;

end


