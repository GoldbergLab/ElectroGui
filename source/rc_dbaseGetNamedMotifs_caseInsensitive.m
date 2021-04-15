function [motifstarts motifends motifdurs] = rc_dbaseGetNamedMotifs_caseInsensitive(dbase, motif)

%Changed in 2010 to account for matlab time sampling problem. using
%dbase.Times2 now


%This function returns starttimes, endtimes, and motifdurs for the named
%motif.  motif is a string ('abc');

[dbase]=dbaseTimesCorrect(dbase);[dbase]=dbaseExcludeDatada(dbase);fs=dbase.Fs;

[spks]=vgm_dbaseGetRaster(dbase, dbase.indx);

dbase.Times2(find(dbase.Times==0))=NaN;
dbase.Times2=dbase.Times-min(dbase.Times(find(dbase.Times>0)));

filestarttimes=dbase.Times2*(3600*24);
%For loop below fixes file overlap problem
for f=1:length(dbase.Times)-1
    if (filestarttimes(f)+dbase.FileLength(f)/fs) > filestarttimes(f+1) %& filestarttimes(f+1)>0 & filestarttimes(f)>0 mod VG
        dbase.FileLength(f)=fs*(filestarttimes(f+1)-filestarttimes(f)); %dbase.FileLength is in samples
    end
    fileendtimes(f)=filestarttimes(f)+dbase.FileLength(f)/fs;
end
fileendtimes(f+1)=filestarttimes(end)+dbase.FileLength(end)/fs;

%below loop through files to get motif start and end times

for i=1:length(dbase.Times)
    if max(dbase.SegmentIsSelected{i});
        if ~isempty(regexpi(concatenateMotifString(dbase.SegmentTitles{i}),motif))
            motifStartNdx=regexpi(concatenateMotifString(dbase.SegmentTitles{i}),motif);
            tempmotifstarts=(dbase.SegmentTimes{i}(motifStartNdx));
            tempmotifends=(dbase.SegmentTimes{i}(motifStartNdx+length(motif)-1,2));
            tempmotifends=tempmotifends(find(tempmotifends<dbase.FileLength(i)));

            if length(tempmotifends)~=0
                %line below makes so doesn't end with a motif start
                tempmotifstarts = tempmotifstarts(find(tempmotifstarts<tempmotifends(end)));
                if length(tempmotifends) ~= length(tempmotifstarts)
                    error('Unequal motif ends and motif starts')
                end
                tempmotifstarts=tempmotifstarts+3600*24*fs*dbase.Times2(i);
                tempmotifends=tempmotifends+3600*24*fs*dbase.Times2(i);
                tempmotifends=tempmotifends./fs; tempmotifstarts=tempmotifstarts./fs;
                motifstarts{i}=tempmotifstarts; motifends{i}=tempmotifends'; %Notice the ' that made motiftimes horizontal

                motifdurs{i}=motifends{i}-motifstarts{i};


            else
                motifstarts{i}=[]; motifends{i}=[]; motifdurs{i}=[];
            end
        else
            motifstarts{i}=[]; motifends{i}=[]; motifdurs{i}=[];
        end
    else
        motifstarts{i}=[]; motifends{i}=[]; motifdurs{i}=[];
    end
end
