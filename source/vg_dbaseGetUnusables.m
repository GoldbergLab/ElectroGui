function dbase=vg_dbaseGetUnusables(dbase);

%This function just generates an n-length vector (where n=#files)
%containing 0 or 1 values indicating if bUnusuable and bContainsSTim was
%checked

unusables=0;
for i=1:length(dbase.Properties.Names{1});
    if strcmp(dbase.Properties.Names{1}{i},'bUnusable');
        unusables=i;
    end
end
if unusables==0;dbase.unusables=[];

else

    dbase.unusables=[];
    for i=1:length(dbase.Times)
        dbase.unusables=[dbase.unusables dbase.Properties.Values{i}{unusables}];
    end
end


stim=0;
for i=1:length(dbase.Properties.Names{1});
    if strcmp(dbase.Properties.Names{1}{i},'bContainsStim');
        stim=i;
    end
end
if stim==0;dbase.stims=[];
else
    dbase.stims=[];
    for i=1:length(dbase.Times)
        dbase.stims=[dbase.stims dbase.Properties.Values{i}{stim}];
    end
end