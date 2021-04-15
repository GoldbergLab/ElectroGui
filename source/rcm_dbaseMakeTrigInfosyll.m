function [dbase]=rcm_dbaseMakeTrigInfosyll(dbase,varargin)

% This function takes dbase and generates (and saves) trigInfo file for all syllables within that dbase.
% optional var: excluding more sylls

%% 

binsize = 0.004;
excludesylls = '-iIlLzZ';
%%
if ~isempty(varargin);
excludesylls=[excludesylls varargin{1}];
end
%%
clear trigInfo;

indsyllInclude = ones(1,length(dbase.allsyllstarts));
indsyllInclude(regexp(dbase.allsyllnames,['[' excludesylls ']' ]))=0;
index_sylls = find(indsyllInclude); % index of non excluded sylls
allsyllnames = dbase.allsyllnames(index_sylls);
allsyllstarts = dbase.allsyllstarts(index_sylls);
allsyllends = dbase.allsyllends(index_sylls);
trigOffsets = allsyllends-allsyllstarts;


%% make trigInfo with selected sylls
bplot = 0;
xl = 0.5;
clear trigger events exclude;
trigger = allsyllstarts;
events = concatenate(dbase.spiketimes);
exclude = [];
trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot,xl,binsize);
%%
trigInfo.currTrigOffset = trigOffsets; 
trigInfo.syllnames = unique(allsyllnames);

dbase.trigInfoSylls=trigInfo;
