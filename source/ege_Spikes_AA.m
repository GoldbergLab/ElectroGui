function [events, labels] = ege_Spikes_AA(data, fs, thres, params)
% Author: Aaron Andalman, 2008.
% Detects spikes using a threshold crossing.  Defines the spike as the
% location of the peak (zenith) and trough (nadir).  Also, addition
% criteria to specified beyond just threshold.
% ElectroGui event detector
% Finds threshold crossings

defaultParams.Names = {'Peak search window (ms)','Addition Criteria (variables: zenith, nadir, duration(nadir-zenith secs), isiNadir, isiZenith)(ex. zenith < 1)'};
defaultParams.Values = {'[-.5,.5]','abs(duration)>0 & height<Inf'};

labels = {'Zenith','Nadir'};
if ischar(data) && strcmp(data,'params')
    events = defaultParams;
    return
elseif ~exist('params', 'var')
    % Use default parameters if none are provided
    params = defaultParams;
else
    % Fill any missing params with defaults
    params = electro_gui.applyDefaultPluginParams(params, defaultParams);
end

    
%Orient data properly
if(size(data,2) > size(data,1))
    data = data';
end

%get peak search window in samples.
win = round((eval(params.Values{1})/1000)*fs);
win = win(1):win(2);
if(isempty(win))
    win = 0;
end

%get threshold crossings.
if thres >= 0
    risingEdgeIdx = find(data(1:end-1)<thres & data(2:end)>=thres);
else
    risingEdgeIdx = find(data(1:end-1)>thres & data(2:end)<=thres);
end

%handle no threshold crossing case.
if(isempty(risingEdgeIdx))
    events{1} = [];
    events{2} = [];
    return;
end

%throwout handles in which the threshold touches the edge

% Create a stack of windowed indices centered around each rising edge
offsets = repmat(win, length(risingEdgeIdx),1);
indices = repmat(risingEdgeIdx, 1, length(win));
indices = offsets + indices;
% Ensure the window indices don't go out of bounds
indices(indices<1) = 1;
indices(indices>length(data)) = length(data);
% Get the windowed data
windowedData = data(indices);
if iscolumn(windowedData)
    % When there is only a single spike, data(indices) weirdly becomes a
    % column vector instead of a row vector. Some kind of strange indexing
    % edge behavior I don't understand, but this fixes it.
    windowedData = windowedData';
end
% Find the min and max value for each window, representing the nadir and
% zenith of this spike.
[nadir, nadirIdx] = min(windowedData,[],2);
[zenith, zenithIdx] = max(windowedData,[],2);
% Adjust indices so that they are relative to the start of the data rather
% than the start of the window
nadirIdx = indices(:,1) + nadirIdx - 1;
zenithIdx = indices(:,1) + zenithIdx - 1;
% Calculate height and duration for filtering criteria
height = zenith - nadir;
duration = ((nadirIdx - zenithIdx) ./ fs);
% Not sure what this is for tbh
isiNadir = [diff(nadirIdx)./fs; (length(data)-nadirIdx(end))./fs];
isiZenith = [diff(zenithIdx)./fs; (length(data)-zenithIdx(end))./fs];

%Process addition criteria.
if(~isempty(params.Values{2}))
    % Execute the user's criterion expression to filter out unacceptable
    % spikes (zenith/nadir pairs)
    criteriaPassed = eval(params.Values{2});
    nadirIdx = nadirIdx(criteriaPassed);
    zenithIdx = zenithIdx(criteriaPassed);
    nadir = nadir(criteriaPassed);
    zenith = zenith(criteriaPassed);
    height = height(criteriaPassed);
    duration = duration(criteriaPassed);
    isiNadir = isiNadir(criteriaPassed);
    isiZenith = isiZenith(criteriaPassed);
end

bUnique = (isiNadir>0) & (isiZenith>0);
nadirIdx = nadirIdx(bUnique);
zenithIdx = zenithIdx(bUnique);
nadir = nadir(bUnique);
zenith = zenith(bUnique);
height = height(bUnique);
duration = duration(bUnique);
isiNadir = isiNadir(bUnique);
isiZenith = isiZenith(bUnique);

events{1} = zenithIdx;
events{2} = nadirIdx;