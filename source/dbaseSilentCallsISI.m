function [catsilentisis catcallisis silentspiketimes callspiketimes silenttime]=dbaseSilentCallsISI(dbase, varargin);

intrvlcutoff=.005;x=.005; fsyllstarttimes=[];fsyllendtimes=[]; callstart=[];callend=[];preallintrvls=[];postallintrvls=[];callspiketimes=[];silentspiketimes=[];callisis=[];silentisis=[];
bPlot1=0;
[filestarttimes fileendtimes syllstarttimes syllendtimes syll_durs preintrvl postintrvl allintrvls] = dbaseGetSylls(dbase);

if isempty(varargin)
[spiketimes,ifr]=dbaseGetRaster(dbase);
else
[spiketimes,ifr]=dbaseGetRaster(dbase, varargin{1});
end

    %Below forloop gets the indx for the bUnusable value--it assumes bUnusalbe
%is in all files (namely the first)
unusables=0;
for i=1:length(dbase.Properties.Names{1})
    if strcmp(dbase.Properties.Names{1}{i},'bUnusable')
        unusables=i;
    end
end

if unusables==0
    errordlg('No Unusables')
end

for r=1:length(allintrvls)
    preallintrvls{r}=allintrvls{r}(1:end-1);
    postallintrvls{r}=allintrvls{r}(2:end);
    fsyllendtimes{r}=[syllendtimes{r} fileendtimes(r)];%this is basically using file endtime instead of infinity in postintrvl
    fsyllstarttimes{r}=[filestarttimes(r) syllstarttimes{r}];
end
songspiketimes=[]; silentspiketimes=[];silentsilentfiles=[];allsongfile=[];songsilentfiles=[]; silentsongfiles=[];justsongsilent=[];justsilentsong=[];songsongfiles=[];
catsilentspikes=[];catcallspikes=[];

for j=1:length(dbase.Times)
    %yoyo below if statement is new to fix problem of empty vectors

    if ~isempty(spiketimes{j}) && dbase.Properties.Values{j}{unusables}
        catsilentspikes{j}=[];catcallspikes{j}=[];allsong=[];

        %|silent|
        if isempty(syllstarttimes{j});
            silentspiketimes{j,1}=spiketimes{j};
            silentisis{j,1}=diff(silentspiketimes{j});%
silenttime{j,1}=fileendtimes(j)-filestarttimes(j);
        end

        if ~isempty(syllstarttimes{j})

            %%ALL SONG
            if length(preallintrvls{j})>0 & length(find(preallintrvls{j}>x))==0 & length(postallintrvls{j})>0 & length(find(postallintrvls{j}>x))==0%|allsong|
                callstart{j}=filestarttimes(j);
                callend{j}=fileendtimes(j);
                callspiketimes{j,1}=spiketimes{j};
                callisis{j,1}=diff(callspiketimes{j,1});

                silentspiketimes{j,1}=[];
                silentisis{j,1}=[];

                allsongfile=[allsongfile j];
                catcallspikes{j}=callspiketimes{j};
                allsong=1; %this is here b/c length(silentspiketimes{j})=0, rightfully, b/c no silenttimes...later i use allsong{j} to see if silentspikes has wrongfully not been assigned.
                calltime{j,1}=fileendtimes(j)-filestarttimes(j);
                silenttime{j,1}=[];

                %|SONGsilent|
            elseif length(find(preallintrvls{j}>x))==0 & length(find(postallintrvls{j}>x))>0
                callstart{j}=filestarttimes(j);
                callend{j}=fsyllendtimes{j}(find(postallintrvls{j}>x));
                callspiketimes{j,1}=spiketimes{j}(find(spiketimes{j}<callend{j}));
                callisis{j,1}=diff(callspiketimes{j,1});

                silentspiketimes{j,1}=spiketimes{j}(find(spiketimes{j}>callend{j}));
                silentisis{j,1}=diff(silentspiketimes{j,1});

                justsongsilent=[justsongsilent j];
                catcallspikes{j}=callspiketimes{j};
                calltime{j,1}=callend{j}(1)-filestarttimes(j);
                silenttime{j,1}=fileendtimes(j)-callend{j}(end);

                %|silentSONG|
            elseif length(find(postallintrvls{j}>x))==0 & length(find(preallintrvls{j}>x))>0
                callstart{j}=fsyllstarttimes{j}(find(preallintrvls{j}>x)+1);
                callend{j}=fileendtimes(j);
                callspiketimes{j,1}=spiketimes{j}(find(spiketimes{j}>callstart{j}));
                callisis{j,1}=diff(callspiketimes{j,1});

                silentspiketimes{j,1}=spiketimes{j}(find(spiketimes{j}<callstart{j}));
                silentisis{j,1}=diff(silentspiketimes{j,1});

                justsilentsong=[justsilentsong j]; catcallspikes{j}=callspiketimes{j};
                silenttime{j,1}=callstart{j}(1)-filestarttimes(j);
                calltime{j,1}=fileendtimes(j)-callstart{j}(end);



                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Below account for files with >1 call that doesn't intersect with a filestart or stop.


            else
                callstart{j}=fsyllstarttimes{j}(find(preallintrvls{j}>x)+1);
                callend{j}=fsyllendtimes{j}(find(postallintrvls{j}>x));
                if length(callend{j})<1
                    callend{j}=fileendtimes(j); %make |        [  ]|
                end
                if callend{j}(1)<callstart{j}(1)
                    callstart{j}=[filestarttimes(j) callstart{j}];%make |[   ]    |
                end
                if callstart{j}(end)>callend{j}(end)
                    callend{j}=[callend{j} fileendtimes(j)];%make |   [ ]   [    ]|
                end

                %%%%%INDEXING callTIMES OUT OF SPIKETIMES, GET call SPIKETIMES AND call ISIS
                %if length(callstart{j})>1
                for r=1:length(callstart{j})
                    callNdx=find(spiketimes{j}>callstart{j}(r) & spiketimes{j}<callend{j}(r));
                    callspiketimes{j,r}=spiketimes{j}(callNdx);
                    catcallspikes{j}=[catcallspikes{j} callspiketimes{j,r}];
                    callisis{j,r}=diff(callspiketimes{j,r});

                    calltime{j,r}=callend{j}(r)-callstart{j}(r);
                end

                % if |silent [song]  silent  [song]   silent| (silent SONG silent)
                if filestarttimes(j)<callstart{j}(1) & callend{j}(end)<fileendtimes(j)
                    for r=1:1+length(callstart{j})
                        if r==1
                            silentNdx=find(spiketimes{j}>filestarttimes(j) & spiketimes{j}<callstart{j}(r));
                            silenttime{j,r}=callstart{j}(r)-filestarttimes(j);
                        end
                        if r~=1 & r<length(callstart{j})+1
                            silentNdx=find(spiketimes{j}>callend{j}(r-1) & spiketimes{j}<callstart{j}(r));
                            silenttime{j,r}=callstart{j}(r)-callend{j}(r-1);
                        end
                        if r==length(callstart{j})+1
                            silentNdx=find(spiketimes{j}>callend{j}(r-1) & spiketimes{j}<fileendtimes(j));
                            silenttime{j,r}=fileendtimes(j)-callend{j}(r-1);
                        end
                        silentspiketimes{j,r}=spiketimes{j}(silentNdx);
                        silentisis{j,r}=diff(silentspiketimes{j,r});

                        catsilentspikes{j}=[catsilentspikes{j} silentspiketimes{j,r}];
                    end
                    silentsilentfiles=[silentsilentfiles j];
                end

                %if |song] silent [song] silent [song] silent| (song silent song silent)
                if filestarttimes(j)==callstart{j}(1) & callend{j}(end) < fileendtimes(j)
                    for r=1:length(callstart{j})
                        if r<length(callstart{j})
                            silentNdx=find(spiketimes{j}>callend{j}(r) & spiketimes{j}<callstart{j}(r+1));
                            silenttime{j,r}=callstart{j}(r+1)-callend{j}(r);
                        end
                        if r==length(callstart{j})
                            silentNdx=find(spiketimes{j}>callend{j}(r) & spiketimes{j}<fileendtimes(j));
                            silenttime{j,r}=fileendtimes(j)-callend{j}(r);
                        end
                        silentspiketimes{j,r}=spiketimes{j}(silentNdx);
                        silentisis{j,r}=diff(silentspiketimes{j,r});

                        catsilentspikes{j}=[catsilentspikes{j} silentspiketimes{j,r}];
                    end
                    songsilentfiles=[songsilentfiles j];
                end

                % if |]  []   []  [| (song silent song)
                if filestarttimes(j)==callstart{j}(1) & fileendtimes(j)==callend{j}(end) & length(callstart{j})>1
                    for r=1:length(callend{j})-1
                        silentNdx=find(spiketimes{j}>callend{j}(r) & spiketimes{j}<callstart{j}(r+1));
                        silentspiketimes{j,r}=spiketimes{j}(silentNdx);
                        silentisis{j,r}=diff(silentspiketimes{j,r});

                        catsilentspikes{j}=[catsilentspikes{j} silentspiketimes{j,r}];
                        silenttime{j,r}=callstart{j}(r+1)-callend{j}(r);
                    end
                    songsongfiles=[songsongfiles j];
                end

                %|silent [song] silent [song] silent [song|
                if fileendtimes(j)==callend{j}(end) & length(find(callstart{j}(1)-intrvlcutoff>filestarttimes(j)))>0
                    for r=1:length(callstart{j})
                        if r==1
                            silentNdx=find(spiketimes{j}>filestarttimes(j) & spiketimes{j}<callstart{j}(1));
                            silenttime{j,r}=callstart{j}(1)-filestarttimes(j);
                        else
                            silentNdx=find(spiketimes{j}>callend{j}(r-1) & spiketimes{j}<callstart{j}(r));
                            silenttime{j,r}=callstart{j}(r)-callend{j}(r-1);
                        end
                        silentspiketimes{j,r}=spiketimes{j}(silentNdx);
                        silentisis{j,r}=diff(silentspiketimes{j,r});

                        catsilentspikes{j}=[catsilentspikes{j} silentspiketimes{j,r}];
                    end
                end

                if length(catsilentspikes{j})==0 & allsong~=1
                    errordlg(['no silentspikes' num2str(j)])
                end

                %%%%%%%%%PLOTTING TO CHECK callSTART/END ACCURACY
                if bPlot1
                    figure;catcallspiketimes=[];catsilentspiketimes=[];
                    for i=1:length(callstart{j})
                        hold on; line([callstart{j}(i)', callstart{j}(i)'],[0,1],'Color','g', 'LineWidth', 3)
                    end
                    for z=1:length(callend{j})
                        hold on; line([callend{j}(z)', callend{j}(z)'],[0,1],'Color','r', 'LineWidth', 3)
                    end
                    catcalls{j}=[];
                    if length(catcallspikes{j})>0;
                        hold on; line([catcallspikes{j}',catcallspikes{j}'],[.25,.75],'Color','yellow','LineWidth', .5)
                    end
                    if length(catsilentspikes{j})>0;
                        hold on; line([catsilentspikes{j}',catsilentspikes{j}'],[.25,.75],'Color','k','LineWidth', .5)
                    end
                end
            end
        end
    else
        callstart{j}=[]; callend{j}=[]; callspiketimes{j,1}=[]; silentspiketimes{j,1}=[]; catcallspikes{j}=[]; catsilentspikes{j}=[];
        catcallisis{j,1}=[]; catsilentisis{j,1}=[]; silenttime{j,1}=[]; calltime{j,1}=[]; silentisis{j,1}=[];callisis{j,1}=[];
    end
end

%%%%%%%CONCATENATE ISIS FOR DISTRIBUTIONS PLOTS
catsilentisis=[];catcallisis=[];
% a=size(silentisis);
% for i=1:a(1)
%     for j=1:a(2)
%         catsilentisis=[catsilentisis silentisis{i,j}];
%     end
% end
a=size(callisis);
for i=1:a(1)
    for j=1:a(2)
        catcallisis=[catcallisis callisis{i,j}];
    end
end

catsilentisis=[];silentisis=[];
a=size(silentspiketimes);
for i=1:a(1);
    for j=1:a(2);
        if ~isempty(silentspiketimes{i,j});
        silentisis{i,j}=diff(silentspiketimes{i,j});
        end
    end
end

catsilentisis=concatenate(silentisis);
