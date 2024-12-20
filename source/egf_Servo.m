function [signal, lab] = egf_Servo(signal, fs, params)
% ElectroGui filter
% Transform a pulse width modulation (PWM) signal into a steady pulse width
% levels.

defaultParams.Names = {};
defaultParams.Values = {};

lab = 'Pulse width (ms)';
if istext(signal) && strcmp(signal, 'params')
    signal = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

% For a servo signal, there should only be two values

risingEdges = find(diff(signal) > 0);
fallingEdges = find(diff(signal) < 0);

if isempty(risingEdges) || isempty(fallingEdges)
    % No pulses at all, or a single partial pulse
    signal = zeros(size(signal));
    return
end

if fallingEdges(1) < risingEdges(1)
    % First falling edge precedes first rising edge. Eliminate the first
    % falling edge
    fallingEdges(1) = [];
end

if fallingEdges(end) < risingEdges(end)
    % Last rising edge is after the last falling edge. Eliminate the last
    % rising edge.
    risingEdges(end) = [];
end

if length(risingEdges) ~= length(fallingEdges)
    % Sanity check
    if length(unique(signal)) > 2
        % This does not appear to be a binary signal
        error('The egf_Servo filter requires digital data, but this appears to be analog.')
    else
        error('Something went wrong with the egf_Servo filter.')
    end
end

% Initialize empty output signal
signal = zeros(size(signal));

% Find the pulse widths in ms
pulseWidths = (fallingEdges - risingEdges) / fs;

% Find locations where the pulse widths change
pulseChangeIdx = find(diff(pulseWidths) ~= 0)+1;
if isempty(pulseChangeIdx)
    % No pulse changes detected
    signal(:) = pulseWidths(1);
    return;
end

for k = 1:length(pulseChangeIdx)-1
    startIdx = risingEdges(pulseChangeIdx(k));
    endIdx = risingEdges(pulseChangeIdx(k+1))-1;
    value = pulseWidths(pulseChangeIdx(k)+1);
    signal(startIdx:endIdx) = value;
end
signal(1:risingEdges(pulseChangeIdx(1))) = pulseWidths(1);
signal(risingEdges(pulseChangeIdx(end)):end) = pulseWidths(end);
