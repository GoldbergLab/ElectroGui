function dbase = cj_dbase_hb_accel_detect_with_curation(dbase,afs,accel_chan,file_range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cj_dbase_hb_accel_detect_with_curation: Detect headbobs in accel. data
% usage: dbase = cj_dbase_hb_accel_detect_with_curation(dbase, afs, 
%                                                   accel_chan, file_range)
%
% where,
%    dbase is an electro_gui dbase
%    afs is the accelerometer sampling rate
%    accel_chan is the dbase channel number of the accelerometer data
%    file_range is an array of filenumbers to analyze
%    dbase is the modified dbase with headbob info added
%
% <long description>
%
% See also: electro_gui
%
% Version: 1.0
% Author:  Caleb Jones
% Email:   cj397=cornell*org
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path = dbase.PathName;
dbase.Fs = 20000; % HARD CODED SAMPLING RATE FOR EPHYS/SOUND
zfiles = dir([path '\' '*chan' num2str(accel_chan) '*.nc']); % change to your file type!
zfilenames = {zfiles.name};
numfiles = size(dbase.Properties,1);
if ~isequal(numfiles,length(zfilenames))
    error('something is wrong')
end

if nargin<4 
    file_range = 1:length(zfilenames);
end
%% exclude files by boolean property
properties_exclude = {'selfgroom'};
exclude = [];
for propnum = 1:length(properties_exclude)
    prop_idx = find(strcmp(dbase.PropertyNames,properties_exclude{propnum}));
    files_prop = find(dbase.Properties(:,prop_idx));
    exclude = [exclude files_prop]; %#ok<AGROW>
end
exclude_files = unique(exclude);

%% loop through all included acc files and look for potential headbobs
pothb = [];

for filenum = file_range
    displayProgress('done with headbob detect for file %d of %d\n',filenum,length(file_range),25)
    if ~ismember(filenum,exclude_files)
        % Search for headbobs
        new_pothb = make_headbob_struct(path, zfilenames{filenum}, filenum, afs);
        % Accumulate newly detected potential headbobs
        pothb = [pothb, new_pothb]; %#ok<AGROW>
    end
end

num_pothb = length(pothb);

%% the curating GUI was generated with help of ChatGPT, I validated it with testing
% ---- now manually curate each potential HB ----
% One slot per candidate (so BACK can't create duplicates)
curated_by_k = repmat(struct('filename', "", 'onset', NaN, 'offset', NaN, ...
    'aa1', [], 'cfs', [], 'samp0', NaN, 'filenum', NaN, 'cyc_abs', []), 1, num_pothb);
curated_keep = false(1, num_pothb);  % accepted mask

k = 1;
while k <= num_pothb

    % Pull candidate
    hb = pothb(k);

    aa1 = hb.aa1(:);
    cfs = hb.cfs;
    Nsnip = numel(aa1);

    % Convert absolute onset/offset -> snippet indices
    on_s  = max(1, min(Nsnip, hb.onset  - hb.samp0 + 1));
    off_s = max(1, min(Nsnip, hb.offset - hb.samp0 + 1));
    if off_s < on_s
        tmp = on_s; on_s = off_s; off_s = tmp;
    end

    % ----------- Build figure -----------
    hFig = figure('Name', sprintf('HB %d/%d | %s', k, num_pothb, hb.filename), ...
        'NumberTitle','off', 'Color','w', ...
        'Units','normalized', 'Position',[0.15 0.15 0.7 0.7]);

    set(hFig,'KeyPressFcn',@(src,evt) key_shortcuts(src,evt));


    % Time axis in seconds for the snippet (absolute time w.r.t. file start)
    t0 = (hb.samp0 - 1) / afs;                 % seconds at first sample in snippet
    t  = t0 + (0:Nsnip-1)/afs;                 % 1xNsnip seconds

    % Layout: reserve bottom strip for buttons so they don't overlap axes labels
    axTop = axes('Parent',hFig,'Units','normalized','Position',[0.08 0.55 0.88 0.38]);
    ax1 = axTop;

    % Top: scalogram (time in seconds)
    imagesc(ax1, t, 1:size(cfs,1), abs(cfs));
    axis(ax1,'tight'); axis(ax1,'xy');
    ylabel(ax1,'Wavelet scale'); box off
    title(ax1, sprintf('Scalogram | %s', hb.filename), 'Interpreter','none');

    % Bottom axes
    axBot = axes('Parent',hFig,'Units','normalized','Position',[0.08 0.18 0.88 0.30]);
    ax2 = axBot;

    plot(ax2, t, aa1, 'k'); hold(ax2,'on'); box off

    % Convert snippet indices -> time in seconds for markers
    t_on  = t(on_s);
    t_off = t(off_s);

    hOn  = plot(ax2, t_on,  aa1(on_s),  'go', 'MarkerFaceColor','g', 'MarkerSize',8);
    hOff = plot(ax2, t_off, aa1(off_s), 'ro', 'MarkerFaceColor','r', 'MarkerSize',8);

    % Vertical lines at onset/offset times
    vOn  = xline(ax2, t_on,  '-', 'Color',[0 0.6 0], 'LineWidth',1.5);
    vOff = xline(ax2, t_off, '-', 'Color',[0.8 0 0], 'LineWidth',1.5);

    xlabel(ax2,'Time (s)');
    ylabel(ax2,'Filtered z axis accel');

    % ---- Initial cycle peak dots (blue) ----
    cyc_s = [];
    hCyc = plot(ax2, NaN, NaN, 'b.', 'MarkerSize', 14); % placeholder handle

    if isfield(hb,'cyc_abs') && ~isempty(hb.cyc_abs)
        cyc_s = hb.cyc_abs - hb.samp0 + 1;
        cyc_s = cyc_s(cyc_s >= 1 & cyc_s <= Nsnip);
        if ~isempty(cyc_s)
            set(hCyc, 'XData', t(cyc_s), 'YData', aa1(cyc_s));
        end
    end



    % Link axes to share common time axis
    linkaxes([ax1 ax2], 'x');

    % ----------- UI state -----------
    state = struct();
    state.editMode = "onset";   % "offset"
    state.action   = "";        % accept/reject/back/quit/save_stub
    state.on_s     = on_s;      % store as snippet index (still fine)
    state.off_s    = off_s;
    state.t        = t;         % store time axis for callbacks
    state.afs      = afs;       % store fs
    state.cyc_s    = cyc_s;
    state.samp0    = hb.samp0;

    % Store handles for callbacks
    guidata(hFig, struct('state',state,'ax2',ax2,'aa1',aa1,'hOn',hOn,'hOff',hOff,'vOn',vOn,'vOff',vOff,...
        'hCyc',hCyc));

    % Click callback on aa1 axis (now uses time axis)
    set(ax2, 'ButtonDownFcn', @(src,evt) click_set_point(hFig));
    set(get(ax2,'Children'), 'HitTest','off'); % let axis catch clicks

    % ----------- Control panel -----------
    ctrlPanel = uipanel('Parent',hFig, ...
        'Units','normalized', ...
        'Position',[0 0 1 0.16], ...
        'BorderType','none', ...
        'BackgroundColor',[0.97 0.97 0.97]);
    uicontrol('Parent',ctrlPanel,'Style','pushbutton', ...
        'String','Toggle onset / offset', ...
        'Units','normalized','Position',[0.02 0.55 0.22 0.35], ...
        'Callback', @(src,evt) toggle_mode(hFig));

    uicontrol('Parent',ctrlPanel,'Style','pushbutton', ...
        'String','Recompute peaks', ...
        'Units','normalized','Position',[0.26 0.55 0.22 0.35], ...
        'Callback', @(src,evt) recompute_peaks(hFig));
    uicontrol('Parent',ctrlPanel,'Style','pushbutton', ...
        'String','Back', ...
        'Units','normalized','Position',[0.02 0.10 0.12 0.30], ...
        'Callback', @(src,evt) set_action(hFig,"back"));

    uicontrol('Parent',ctrlPanel,'Style','pushbutton', ...
        'String','Quit', ...
        'Units','normalized','Position',[0.16 0.10 0.12 0.30], ...
        'Callback', @(src,evt) set_action(hFig,"quit"));

    uicontrol('Parent',ctrlPanel,'Style','pushbutton', ...
        'String','REJECT', ...
        'Units','normalized','Position',[0.62 0.15 0.15 0.65], ...
        'FontWeight','bold', ...
        'FontSize',12, ...
        'BackgroundColor',[0.95 0.75 0.75], ...
        'Callback', @(src,evt) set_action(hFig,"reject"));

    uicontrol('Parent',ctrlPanel,'Style','pushbutton', ...
        'String','ACCEPT', ...
        'Units','normalized','Position',[0.80 0.15 0.15 0.65], ...
        'FontWeight','bold', ...
        'FontSize',12, ...
        'BackgroundColor',[0.75 0.95 0.75], ...
        'Callback', @(src,evt) set_action(hFig,"accept"));

    % Mode text
    txt = annotation(hFig,'textbox',[0.02 0.93 0.3 0.05], ...
        'String', sprintf('Editing: %s', state.editMode), ...
        'EdgeColor','none','FontWeight','bold');
    setappdata(hFig,'modeText',txt);


    % ----------- Wait for user action -----------
    uiwait(hFig);

    % Pull final state after UI resumes
    data = guidata(hFig);
    state = data.state;

    % If figure was closed
    if ~isgraphics(hFig)
        break;
    end

    action = state.action;
    close(hFig);

    switch action
        case "accept"
            on_s  = min(state.on_s, state.off_s);
            off_s = max(state.on_s, state.off_s);

            onset_abs  = hb.samp0 + on_s  - 1;
            offset_abs = hb.samp0 + off_s - 1;

            cyc_abs = [];
            if isfield(state,'cyc_s') && ~isempty(state.cyc_s)
                cyc_abs = hb.samp0 + state.cyc_s - 1;
            end

            curated_by_k(k).filename = hb.filename;
            curated_by_k(k).onset    = onset_abs;
            curated_by_k(k).offset   = offset_abs;
            curated_by_k(k).samp0    = hb.samp0;
            curated_by_k(k).aa1      = hb.aa1;
            curated_by_k(k).cfs      = hb.cfs;
            curated_by_k(k).filenum  = hb.filenum;
            curated_by_k(k).cyc_abs  = cyc_abs;

            curated_keep(k) = true;

            k = k + 1;


        case "reject"
            curated_keep(k) = false;
            curated_by_k(k) = struct('filename', "", 'onset', NaN, 'offset', NaN, ...
                'aa1', [], 'cfs', [], 'samp0', NaN, 'filenum', NaN, 'cyc_abs', []);
            k = k + 1;
        case "back"
            k = max(1, k - 1);

        case "quit"
            break;

        otherwise
            % safety
            k = k + 1;
    end

end
curated_hbs = curated_by_k(curated_keep);
[curated_hbs(:).cfs] = deal([]); % trim off data so dbase is reasonably sized 
[curated_hbs(:).aa1] = deal([]);
% store headbob stuff in the dbase
for hbnum = 1:size(curated_hbs,2)
    %make marker time and isselected and title
    cursize = size(dbase.MarkerTimes{curated_hbs(hbnum).filenum},1)+1;
    dbase.MarkerTimes{curated_hbs(hbnum).filenum}(cursize,1) = curated_hbs(hbnum).onset*(dbase.Fs/afs);
    dbase.MarkerTimes{curated_hbs(hbnum).filenum}(cursize,2) = curated_hbs(hbnum).offset*(dbase.Fs/afs);
    cursizesel = length(dbase.MarkerIsSelected{curated_hbs(hbnum).filenum})+1;
    dbase.MarkerIsSelected{curated_hbs(hbnum).filenum}(cursizesel) = 1;
    cursizemar = length(dbase.MarkerTitles{curated_hbs(hbnum).filenum})+1;
    dbase.MarkerTitles{curated_hbs(hbnum).filenum}{cursizemar} = 'h';
end
hbfiles = unique([curated_hbs.filenum]);
dbase.headbob_detects = curated_hbs;
% populate a bheadbob property
if ~any(ismember(dbase.PropertyNames,'bHB'))
    dbase.PropertyNames{end+1} = 'bHB';
    curnum = size(dbase.Properties,2);
    dbase.Properties(:,curnum+1) = zeros(size(dbase.Properties,1),1);
    hbpidx = curnum+1;
else
    hbpidx = find(ismember(dbase.PropertyNames,'bHB')); % only adds property values, does not get rid of old 1's if they exist
end
for filenum = 1:length(hbfiles)
    dbase.Properties(hbfiles(filenum),hbpidx) = 1;
end
end

function click_set_point(figHandle)
data = guidata(figHandle);
ax2  = data.ax2;
aa1  = data.aa1;
st   = data.state;

cp = get(ax2, 'CurrentPoint');
tClick = cp(1,1);

% Convert clicked time -> nearest index in snippet
[~, x] = min(abs(st.t - tClick));
x = max(1, min(numel(aa1), x));

if st.editMode == "onset"
    st.on_s = x;
else
    st.off_s = x;
end

% Update markers/lines using time axis
t_on  = st.t(st.on_s);
t_off = st.t(st.off_s);

set(data.hOn,  'XData', t_on,  'YData', aa1(st.on_s));
set(data.hOff, 'XData', t_off, 'YData', aa1(st.off_s));
data.vOn.Value  = t_on;
data.vOff.Value = t_off;

data.state = st;
guidata(figHandle, data);
end

function toggle_mode(figHandle)
data = guidata(figHandle);
st = data.state;

if st.editMode == "onset"
    st.editMode = "offset";
else
    st.editMode = "onset";
end

data.state = st;
guidata(figHandle, data);

txt = getappdata(figHandle,'modeText');
if isgraphics(txt)
    txt.String = sprintf('Editing: %s', st.editMode);
end
end

function set_action(figHandle, actionStr)
data = guidata(figHandle);
data.state.action = actionStr;
guidata(figHandle, data);
uiresume(figHandle);
end
function recompute_peaks(figHandle)
data = guidata(figHandle);
st   = data.state;
aa1  = data.aa1;

% Current edited onset/offset (snippet indices)
on_s  = st.on_s;
off_s = st.off_s;

% Enforce ordering
if off_s < on_s
    tmp = on_s; on_s = off_s; off_s = tmp;
    st.on_s  = on_s;
    st.off_s = off_s;
end

% Guard
on_s  = max(1, min(numel(aa1), on_s));
off_s = max(1, min(numel(aa1), off_s));
if off_s <= on_s
    st.cyc_s = [];
    set(data.hCyc, 'XData', NaN, 'YData', NaN);
    data.state = st;
    guidata(figHandle, data);
    return;
end

% EXACT same peak detection as you used:
[~, locs] = findpeaks(aa1(on_s:off_s), ...
    'MinPeakDistance', 500, ...
    'MinPeakHeight', 0);

% Your same early-peak removal rule
if ~isempty(locs) && locs(1) < 200
    locs = locs(2:end);
end

% Convert locs (relative to on_s) -> snippet indices
cyc_s = (on_s - 1) + locs;

% Clip to bounds
cyc_s = cyc_s(cyc_s >= 1 & cyc_s <= numel(aa1));

% Update plot
if isempty(cyc_s)
    set(data.hCyc, 'XData', NaN, 'YData', NaN);
else
    set(data.hCyc, 'XData', st.t(cyc_s), 'YData', aa1(cyc_s));
end

% Store into state so ACCEPT writes it into curated_hbs
st.cyc_s = cyc_s;

data.state = st;
guidata(figHandle, data);
end
