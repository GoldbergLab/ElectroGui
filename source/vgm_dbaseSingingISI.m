function [boutstart boutend boutspiketimes quietspiketimes catboutspikes catquietspikes catboutisis catquietisis catdiffboutisis catdiffquietisis quiettime bouttime quietifrs boutifrs catboutifrs catquietifrs catdiffquietifrs catdiffboutifrs spiketimes]=vgm_dbaseSingingISI(dbase, varargin)

%This is the version (originally The old) that is acutally the revised version that correctly returns boutstarts
%and boutends. Use this version.

%This code goes through all files with song (has spikes and bUnusable=0)
%and returns the spiketimes during singing and during 'quiet'. Here, quiet
%equals interbout silence.

intrvlcutoff=.3;x=.3; fsyllstarttimes=[];fsyllendtimes=[]; boutstart=[];boutend=[];preallintrvls=[];postallintrvls=[];boutspiketimes=[];quietspiketimes=[];boutisis=[];quietisis=[];
bPlot1=0;
[filestarttimes fileendtimes syllstarttimes syllendtimes syll_durs preintrvl postintrvl allintrvls] = vgm_dbaseGetSylls(dbase);
if isempty(varargin)
    [spiketimes,ifr]=vgm_dbaseGetRaster(dbase);
else
    [spiketimes,ifr]=vgm_dbaseGetRaster(dbase,dbase.indx);
end

%Below forloop gets the indx for the bUnusable value--it assumes bUnusalbe
%is in all files (namely the first)
unusables=0;
for i=1:length(dbase.Properties.Names{1})
    if strcmp(dbase.Properties.Names{1}{i},'bUnusable')
        unusables=i;
    end
end

BOS=0;
for i=1:length(dbase.Properties.Names{1})
    if strcmp(dbase.Properties.Names{1}{i},'bBOS')
        BOS=i;
    end
end

if unusables==0
    %errordlg('No Unusables')
end

for r=1:length(allintrvls)
    preallintrvls{r}=allintrvls{r}(1:end-1);
    postallintrvls{r}=allintrvls{r}(2:end);
    fsyllendtimes{r}=[syllendtimes{r} fileendtimes(r)];%this is basically using file endtime instead of infinity in postintrvl
    fsyllstarttimes{r}=[filestarttimes(r) syllstarttimes{r}];
end
songspiketimes=[]; quietspiketimes=[];quietquietfiles=[];allsongfile=[];songquietfiles=[]; quietsongfiles=[];justsongquiet=[];justquietsong=[];songsongfiles=[];
catquietspikes=cell(length(dbase.Times),1);catboutspikes=cell(length(dbase.Times),1);


for j=1:length(dbase.Times)
    %yoyo below if statement is new to fix problem of empty vectors
    if length(spiketimes{j})>0 & length(allintrvls{j})>0 & ~dbase.Properties.Values{j}{unusables}
        catquietspikes{j}=[];catboutspikes{j}=[];allsong=[];
        
        %%ALL SONG
        if length(preallintrvls{j})>0 & length(find(preallintrvls{j}>x))==0 & length(postallintrvls{j})>0 & length(find(postallintrvls{j}>x))==0%|allsong|
            boutstart{1,j}=filestarttimes(j);
            boutend{1,j}=fileendtimes(j);
            boutspiketimes{j,1}=spiketimes{j};
            boutisis{j,1}=diff(boutspiketimes{j,1});
            boutifrs{j,1}=1./boutisis{j,1};
            quietspiketimes{j,1}=[];
            quietisis{j,1}=[];
            quietifrs{j,1}=[];
            allsongfile=[allsongfile j];
            catboutspikes{j}=boutspiketimes{j};
            allsong=1; %this is here b/c length(quietspiketimes{j})=0, rightfully, b/c no quiettimes...later i use allsong{j} to see if quietspikes has wrongfully not been assigned.
            bouttime{j,1}=fileendtimes(j)-filestarttimes(j);
            quiettime{j,1}=[];
            
            %|SONGQUIET|
        elseif isempty(find(preallintrvls{j}>x)) && ~isempty(find(postallintrvls{j}>x))
            boutstart{1,j}=filestarttimes(j);
            boutend{1,j}=fsyllendtimes{j}(find(postallintrvls{j}>x));
            boutspiketimes{j,1}=spiketimes{j}(find(spiketimes{j}<boutend{1,j}));
            boutisis{j,1}=diff(boutspiketimes{j,1});
            boutifrs{j,1}=1./boutisis{j,1};
            quietspiketimes{j,1}=spiketimes{j}(find(spiketimes{j}>boutend{1,j}));
            quietisis{j,1}=diff(quietspiketimes{j,1});
            quietifrs{j,1}=1./quietisis{j,1};
            justsongquiet=[justsongquiet j];
            catboutspikes{j}=boutspiketimes{j};
            bouttime{j,1}=boutend{1,j}(1)-filestarttimes(j);
            quiettime{j,1}=fileendtimes(j)-boutend{1,j}(end);
            
            %|QUIETSONG|
        elseif length(find(postallintrvls{j}>x))==0 & length(find(preallintrvls{j}>x))>0
            boutstart{1,j}=fsyllstarttimes{j}(find(preallintrvls{j}>x)+1);
            boutend{1,j}=fileendtimes(j);
            boutspiketimes{j,1}=spiketimes{j}(find(spiketimes{j}>boutstart{1,j}));
            boutisis{j,1}=diff(boutspiketimes{j,1});
            boutifrs{j,1}=1./boutisis{j,1};
            quietspiketimes{j,1}=spiketimes{j}(find(spiketimes{j}<boutstart{1,j}));
            quietisis{j,1}=diff(quietspiketimes{j,1});
            quietifrs{j,1}=1./quietisis{j,1};
            justquietsong=[justquietsong j]; catboutspikes{j}=boutspiketimes{j};
            quiettime{j,1}=boutstart{1,j}(1)-filestarttimes(j);
            bouttime{j,1}=fileendtimes(j)-boutstart{1,j}(end);
            
            %%%%%%Below account for files with >1 bout that doesn't intersect with a filestart or stop.
            
        else
            boutstart{1,j}=fsyllstarttimes{j}(find(preallintrvls{j}>x)+1);
            boutend{1,j}=fsyllendtimes{j}(find(postallintrvls{j}>x));
            if length(boutend{1,j})<1
                boutend{1,j}=fileendtimes(j); %make |        [  ]|
            end
            if boutend{1,j}(1)<boutstart{1,j}(1)
                boutstart{1,j}=[filestarttimes(j) boutstart{1,j}];%make |[   ]    |
            end
            if boutstart{1,j}(end)>boutend{1,j}(end)
                boutend{1,j}=[boutend{1,j} fileendtimes(j)];%make |   [ ]   [    ]|
            end

            % eliminate bouts that are smaller than 3 syllables long (modified by VG)
            minSyllnum = 3;
            for r=1:length(boutstart{1,j})
                Syllnum = 1+ length(syllstarttimes{j}(syllstarttimes{j} > boutstart{1,j}(r)...
                    & syllstarttimes{j} < boutend{1,j}(r)));
                if Syllnum < minSyllnum
                    boutstart{1,j}(r) = NaN;
                    boutend{1,j}(r) = NaN;
                end
            end 
            boutstart{1,j} = boutstart{1,j}(~isnan(boutstart{1,j}));
            boutend{1,j} = boutend{1,j}(~isnan(boutend{1,j}));
            
            if isempty(boutstart{1,j})
                boutstart{1,j}=[]; boutend{1,j}=[]; boutspiketimes{j,1}=[]; quietspiketimes{j,1}=[]; catboutspikes{j,1}=[]; catquietspikes{j,1}=[];
                catboutisis{j,1}=[]; catquietisis{j,1}=[]; quiettime{j,1}=[]; bouttime{j,1}=[]; quietifrs{j,1}=[];boutifrs{j,1}=[];
                continue
            end

            %%%%%INDEXING BOUTTIMES OUT OF SPIKETIMES, GET BOUT SPIKETIMES AND BOUT ISIS
            %if length(boutstart{1,j})>1
            for r=1:length(boutstart{1,j})
                boutNdx=find(spiketimes{j}>boutstart{1,j}(r) & spiketimes{j}<boutend{1,j}(r));
                boutspiketimes{j,r}=spiketimes{j}(boutNdx);
                catboutspikes{j}=[catboutspikes{j} boutspiketimes{j,r}];
                boutisis{j,r}=diff(boutspiketimes{j,r});
                if length(boutisis{j,r})>0;
                    boutifrs{j,r}=1./boutisis{j,r};
                else boutifrs{j,r}=[];
                end
                bouttime{j,r}=boutend{1,j}(r)-boutstart{1,j}(r);
            end
            
            % if |quiet [song]  quiet  [song]   quiet| (quiet SONG quiet)
            if filestarttimes(j)<boutstart{1,j}(1) & boutend{1,j}(end)<fileendtimes(j)
                for r=1:1+length(boutstart{1,j})
                    if r==1
                        quietNdx=find(spiketimes{j}>filestarttimes(j) & spiketimes{j}<boutstart{1,j}(r));
                        quiettime{j,r}=boutstart{1,j}(r)-filestarttimes(j);
                    end
                    if r~=1 & r<length(boutstart{1,j})+1
                        quietNdx=find(spiketimes{j}>boutend{1,j}(r-1) & spiketimes{j}<boutstart{1,j}(r));
                        quiettime{j,r}=boutstart{1,j}(r)-boutend{1,j}(r-1);
                    end
                    if r==length(boutstart{1,j})+1
                        quietNdx=find(spiketimes{j}>boutend{1,j}(r-1) & spiketimes{j}<fileendtimes(j));
                        quiettime{j,r}=fileendtimes(j)-boutend{1,j}(r-1);
                    end
                    quietspiketimes{j,r}=spiketimes{j}(quietNdx);
                    quietisis{j,r}=diff(quietspiketimes{j,r});
                    if length(quietisis{j,r})>0
                        quietifrs{j,r}=1./quietisis{j,r};
                    else quietifrs{j,r}=[];
                    end
                    catquietspikes{j}=[catquietspikes{j} quietspiketimes{j,r}];
                end
                quietquietfiles=[quietquietfiles j];
            end
            
            %if |song] quiet [song] quiet [song] quiet| (song quiet song quiet)
            if filestarttimes(j)==boutstart{1,j}(1) & boutend{1,j}(end) < fileendtimes(j)
                for r=1:length(boutstart{1,j})
                    if r<length(boutstart{1,j})
                        quietNdx=find(spiketimes{j}>boutend{1,j}(r) & spiketimes{j}<boutstart{1,j}(r+1));
                        quiettime{j,r}=boutstart{1,j}(r+1)-boutend{1,j}(r);
                    end
                    if r==length(boutstart{1,j})
                        quietNdx=find(spiketimes{j}>boutend{1,j}(r) & spiketimes{j}<fileendtimes(j));
                        quiettime{j,r}=fileendtimes(j)-boutend{1,j}(r);
                    end
                    quietspiketimes{j,r}=spiketimes{j}(quietNdx);
                    quietisis{j,r}=diff(quietspiketimes{j,r});
                    quietifrs{j,r}=1./quietisis{j,r};
                    catquietspikes{j}=[catquietspikes{j} quietspiketimes{j,r}];
                end
                songquietfiles=[songquietfiles j];
            end
            
            % if |]  []   []  [| (song quiet song)
            if filestarttimes(j)==boutstart{1,j}(1) & fileendtimes(j)==boutend{1,j}(end) & length(boutstart{1,j})>1
                for r=1:length(boutend{1,j})-1
                    quietNdx=find(spiketimes{j}>boutend{1,j}(r) & spiketimes{j}<boutstart{1,j}(r+1));
                    quietspiketimes{j,r}=spiketimes{j}(quietNdx);
                    quietisis{j,r}=diff(quietspiketimes{j,r});
                    quietifrs{j,r}=1./quietisis{j,r};
                    catquietspikes{j}=[catquietspikes{j} quietspiketimes{j,r}];
                    quiettime{j,r}=boutstart{1,j}(r+1)-boutend{1,j}(r);
                end
                songsongfiles=[songsongfiles j];
            end
            
            %|quiet [song] quiet [song] quiet [song|
            if fileendtimes(j)==boutend{1,j}(end) & length(find(boutstart{1,j}(1)-intrvlcutoff>filestarttimes(j)))>0
                for r=1:length(boutstart{1,j})
                    if r==1
                        quietNdx=find(spiketimes{j}>filestarttimes(j) & spiketimes{j}<boutstart{1,j}(1));
                        quiettime{j,r}=boutstart{1,j}(1)-filestarttimes(j);
                    else
                        quietNdx=find(spiketimes{j}>boutend{1,j}(r-1) & spiketimes{j}<boutstart{1,j}(r));
                        quiettime{j,r}=boutstart{1,j}(r)-boutend{1,j}(r-1);
                    end
                    quietspiketimes{j,r}=spiketimes{j}(quietNdx);
                    quietisis{j,r}=diff(quietspiketimes{j,r});
                    quietifrs{j,r}=1./quietisis{j,r};
                    catquietspikes{j}=[catquietspikes{j} quietspiketimes{j,r}];
                end
            end
            
            if length(catquietspikes{j})==0 & allsong~=1
                errordlg(['no quietspikes' num2str(j)])
            end
            
            %%%%%%%%%PLOTTING TO CHECK BOUTSTART/END ACCURACY
            if bPlot1
                figure;catboutspiketimes=[];catquietspiketimes=[];
                for i=1:length(boutstart{1,j})
                    hold on; line([boutstart{1,j}(i)', boutstart{1,j}(i)'],[0,1],'Color','g', 'LineWidth', 3)
                end
                for z=1:length(boutend{1,j})
                    hold on; line([boutend{1,j}(z)', boutend{1,j}(z)'],[0,1],'Color','r', 'LineWidth', 3)
                end
                catbouts{j}=[];
                if length(catboutspikes{j})>0;
                    hold on; line([catboutspikes{j}',catboutspikes{j}'],[.25,.75],'Color','yellow','LineWidth', .5)
                end
                if length(catquietspikes{j})>0;
                    hold on; line([catquietspikes{j}',catquietspikes{j}'],[.25,.75],'Color','k','LineWidth', .5)
                end
            end
        end
        tst=[];
    else
        boutstart{1,j}=[]; boutend{1,j}=[]; boutspiketimes{j,1}=[]; quietspiketimes{j,1}=[]; catboutspikes{j,1}=[]; catquietspikes{j,1}=[];
        catboutisis{j,1}=[]; catquietisis{j,1}=[]; quiettime{j,1}=[]; bouttime{j,1}=[]; quietifrs{j,1}=[];boutifrs{j,1}=[];
    end
end

%%%%%%%GET DIFF ISIS TO EXAMINE TUMULT DURING SONG VS QUIET
diffquietisis=[];diffboutisis=[];diffquietifrs=[];diffboutifrs=[];
[a b]=size(quietisis);
for j=1:a
    for r=1:b
        diffquietisis{j,r}=diff(quietisis{j,r});
        diffquietifrs{j,r}=diff(quietifrs{j,r});
    end
end
[a b]=size(boutisis);
for j=1:a
    for r=1:b
        diffboutisis{j,r}=diff(boutisis{j,r});
        diffboutifrs{j,r}=diff(boutifrs{j,r});
    end
end

%%%%%%%CONCATENATE ISIS FOR DISTRIBUTIONS PLOTS
catquietisis=[];catboutisis=[];catquietifrs=[];catboutifrs=[];catdiffquietisis=[];catdiffquietifrs=[];
a=size(quietisis);catdiffboutisis=[];catboutifrs=[];catdiffboutifrs=[];
%for i=1:length(quietisis)QUICK REPAIR 091508;
for i=1:a(1)
    for j=1:a(2)
        catquietisis=[catquietisis quietisis{i,j}];
        catdiffquietisis=[catdiffquietisis diffquietisis{i,j}];
        catquietifrs=[catquietifrs quietifrs{i,j}];
        catdiffquietifrs=[catdiffquietifrs diffquietifrs{i,j}];
    end
end

a=size(boutisis);
for i=1:a(1)
    for j=1:a(2)
        catboutisis=[catboutisis boutisis{i,j}];
        catdiffboutisis=[catdiffboutisis diffboutisis{i,j}];
        catboutifrs=[catboutifrs boutifrs{i,j}];
        catdiffboutifrs=[catdiffboutifrs diffboutifrs{i,j}];
    end
end