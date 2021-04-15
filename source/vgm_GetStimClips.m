function dbase=vgm_GetStimClips(dbase)

%this function creates field dbase.stimclips
%each stim file gets its own clip


%get files with stims
if ~isfield(dbase,'stims');
    dbase=vg_dbaseGetUnusables(dbase);
end

load([dbase.PathName '\exper.mat']);
exper.dir=[dbase.PathName '\'];
dbase.exper=exper;
chan=dbase.EventSources{dbase.indx}(end);
preMs=10;
postMs=25;
yl=[-2 2];

for i=1:length(dbase.FileLength);
    
tmp=strfind(dbase.SoundFiles(i,1).name,'_');
dbase.FileList(i)=str2num(dbase.SoundFiles(i,1).name(tmp(1)+2:tmp(2)-1));
end

bplot=0;

dbase.stimfiles=dbase.FileList(find(dbase.stims));
for i=1:length(dbase.stimfiles);
    n=dbase.stimfiles(i);
    signal{i}=loadData(dbase.exper,n,chan);
    %     figure;plot([1/40000:1/40000:length(signal{i})/40000],signal{i});title(num2str(n));
    dbase.stimclips.anticlips{i} = vgm_clipStimFromSignal(signal{i},preMs,postMs,yl,bplot);
    dbase.stimclips.realfilenum{i}=n;
    dbase.stimclips.dbasefilenum{i}=i;
    title([num2str(n) '-' num2str(i)]);
    dbase.stimclips.antixl=[preMs postMs];
end

% firstfile = 1;
preMs=500;postMs=500;
% for i=1:length(find(dbase.stims));
for i=1:length(dbase.stimfiles)
%     num=find(dbase.stims)+firstfile-1;
%     n=num(i);
    n=dbase.stimfiles(i);

    signal{i}=loadData(dbase.exper,n,chan);
    %     figure;plot([1/40000:1/40000:length(signal{i})/40000],signal{i});
    %     title(num2str(n));
    dbase.stimclips.orthoclips{i} = vgm_clipStimFromSignal(signal{i},preMs,postMs,yl,bplot);
    dbase.stimclips.realfilenum{i}=n;
    dbase.stimclips.dbasefilenum{i}=i;
    title([num2str(n) '-' num2str(i)]);
    dbase.stimclips.orthoxl=[preMs postMs];
end
dbase.stimclips.plotscript='figure;plot(linspace(-1*dbase.stimclips.orthoxl(1), dbase.stimclips.orthoxl(2), length(dbase.stimClips.orthoclips{i})), dbase.stimClips.orthoclips{i}(1:min([5 size(dbase.stimClips.orthoclips{i},1)]),:));';