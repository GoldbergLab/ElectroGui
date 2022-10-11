function [filestarttimes fileendtimes syllstarttimes syllendtimes syll_durs preintrvl postintrvl allintrvls syllnames] = dbaseGetSylls(dbase);

%Changed in 2010 dbase.Times2

%This function returns syll related info for dbase. Substitutes for
%syllable component of GetRasterSylls.

[dbase]=dbaseTimesCorrect(dbase);[dbase]=dbaseExcludeDatada(dbase);fs=dbase.Fs;

dbase.Times2(find(dbase.Times==0))=NaN;
dbase.Times2=dbase.Times-min(dbase.Times(find(dbase.Times>0)));

filestarttimes=dbase.Times2*(3600*24);
%For loop below fixes file overlap problem
if length(dbase.Times2)>1
    for f=1:length(dbase.Times2)-1
        if (filestarttimes(f)+dbase.FileLength(f)/fs) > filestarttimes(f+1) %& filestarttimes(f+1)>0 & filestarttimes(f)>0 mod VG
            dbase.FileLength(f)=fs*(filestarttimes(f+1)-filestarttimes(f)); %dbase.FileLength is in samples
        end
        fileendtimes(f)=filestarttimes(f)+dbase.FileLength(f)/fs;
    end
    fileendtimes(f+1)=filestarttimes(end)+dbase.FileLength(end)/fs;
else
    fileendtimes=filestarttimes+dbase.FileLength/fs;
end

for i=1:length(dbase.Times2)

    if max(dbase.SegmentIsSelected{i});
        tempsyllstarttimes=dbase.SegmentTimes{i}(find(dbase.SegmentIsSelected{i}),1);
        tempsyllendtimes=dbase.SegmentTimes{i}(find(dbase.SegmentIsSelected{i}),2);
        tempsyllendtimes=tempsyllendtimes(find(tempsyllendtimes<dbase.FileLength(i)));
        names=dbase.SegmentTitles{i};
        names=names(find(dbase.SegmentIsSelected{i}));

        for jj=1:length(names);if isempty(names{jj});names{jj}='-';end;end

        if length(tempsyllendtimes)~=0
            %line below makes so doesn't end with a syll start
            tempsyllstarttimes = tempsyllstarttimes(find(tempsyllstarttimes<tempsyllendtimes(end)));
            names=names(find(tempsyllstarttimes<tempsyllendtimes(end)));
            if length(tempsyllendtimes) ~= length(tempsyllstarttimes)
                error('Unequal syll ends and syll starts')
            end
            tempsyllstarttimes=tempsyllstarttimes+3600*24*fs*dbase.Times2(i);
            tempsyllendtimes=tempsyllendtimes+3600*24*fs*dbase.Times2(i);
            tempsyllendtimes=tempsyllendtimes./fs; tempsyllstarttimes=tempsyllstarttimes./fs;
            syllstarttimes{i}=tempsyllstarttimes'; syllendtimes{i}=tempsyllendtimes'; %Notice the ' that made sylltimes horizontal
            syllnames{i}=names;
            syll_durs{i}=syllendtimes{i}-syllstarttimes{i};
            intrvls{i}=syllstarttimes{i}(2:end)-syllendtimes{i}(1:end-1);
            postintrvl{i}=[intrvls{i} Inf];%this is where you fix green line problem!!
            preintrvl{i}=[Inf intrvls{i}];
            allintrvls{i}=[(syllstarttimes{i}(1)-filestarttimes(i)) intrvls{i} (fileendtimes(i)-syllendtimes{i}(end))];
        end
    else
        syllstarttimes{i}=[]; syllendtimes{i}=[]; syll_durs{i}=[]; intrvls{i}=[]; postintrvl{i}=[]; preintrvl{i}=[]; allintrvls{i}=[];syllnames{i}=[];
    end
end
