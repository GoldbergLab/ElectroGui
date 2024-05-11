function segs = egg_DA_segmenter(sound, a,fs,th,params)
% ElectroGui segmenter

defaultParams.Names = {'Minimum duration (ms)','Minimum interval (ms)','Mininum duration for splitting (ms)','Minimum interval for splitting (ms)'};
defaultParams.Values = {'7', '7','7','0'};

if ischar(sound) && strcmp(sound, 'params')
    segs = defaultParams;
    return
end

if ~exist('params', 'var')
    params = defaultParams;
end

min_dur = str2double(params.Values{1})/1000;
min_stop = str2double(params.Values{2})/1000;

if params.IsSplit == 1
    min_dur = str2double(params.Values{3})/1000;
    min_stop = str2double(params.Values{4})/1000;
end

if th < 0
    a = -a;
    th = -th;
end
th = th-min(a);
a = a-min(a);

% Find threshold crossing points
f = [];
a = [0; a; 0];
f(:,1) = find(a(1:end-1)<th & a(2:end)>=th)-1;
f(:,2) = find(a(1:end-1)>=th & a(2:end)<th)-1;
a = a(2:end-1);

% Eliminate VERY short syllables
i = f(:,2)-f(:,1)>min_dur/2*fs;
f = f(i,:);

% Extend syllables to a lower threshold
if params.IsSplit == 0
    warning off
    mn = mean(a(a<th));
    st = std(a(a<th));
    warning on
    thnew = min([th mn+2*st]);
    for c=1:size(f,1)
        f(c,1)=max([1; find(a(1:f(c,1)-1)<thnew)]);
        f(c,2)=min([length(a); f(c,2)+find(a(f(c,2)+1:end)<th/2)]);
    end
end

% Eliminate short syllables
i = f(:,2)-f(:,1)>min_dur*fs;
f = f(i,:);

if isempty(f)
    segs = zeros(0,2);
    return
end

% Eliminate short intervals
if size(f,1)>1
    i = [find(f(2:end,1)-f(1:end-1,2) > min_stop*fs); length(f)];
    f = [f([1; i(1:end-1)+1],1) f(i,2)];
end

segs = f;