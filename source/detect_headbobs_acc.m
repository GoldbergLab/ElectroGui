function OUT = detect_headbobs_acc(acc_z, fs)
% 
%
% Inputs:
%   acc_z : [Nx1] z-axis acceleration (already in "acc units" after volt2acc)
%   fs    : sampling rate (should be 5000)
%
% Output struct fields:
%   onsets, offsets : sample indices (fs Hz)
%   aa1             : filtered/gated accel signal used for CWT
%   mask            : wavelet_threshold boolean
%   cfs             : CWT(aa1) coefficients (magnitude useful)
%   wmean_list      : cell array of wmean vectors per accepted segment
%   debug           : misc details

if nargin < 2 || isempty(fs), fs = 5000; end
acc_z = double(acc_z(:));

% filter
aa1 = medfilt1(acc_z, 500) - medfilt1(acc_z, 2000);
aa1 = (aa1 - mean(aa1)) .* acc_z;
aa1(abs(aa1) > 0.5) = 0;

% wavelet transform
cfs   = cwt(aa1, fs, 'morse', 'WaveletParameters', [3,25]);
cfs_d = cwt(acc_z - aa1, fs, 'morse', 'WaveletParameters', [3,25]); %#ok<NASGU>

% ---------------- Initial segmentation ----------------
mask = mean(abs(cfs(85:90,:)), 1) > 0.04;     % 1xN logical
segs = diff(mask);

onsets  = find(segs > 0);
offsets = find(segs < 0);

% Boundary handling
if numel(onsets) > numel(offsets)
    offsets(end+1) = length(aa1);
elseif numel(onsets) < numel(offsets)
    onsets = [1 onsets];
end

% Duration filter 
dur = (offsets - onsets) / fs;
keep = (dur > 0.6 & dur < 3.5);
onsets  = onsets(keep);
offsets = offsets(keep);

%  Additional refinement 
temp_ind = [];
wmean_list = {};

if ~isempty(onsets)
    for m = 1:numel(onsets)
        wmean = mean(abs(cfs(:, onsets(m):offsets(m))), 2); % [nScales x 1]
        wavelet_f = diff(wmean > 0.05);

        wavelet_f_onset = find(wavelet_f > 0, 1);

        if ~isempty(wavelet_f_onset)
            cond1 = wavelet_f_onset >= 80;
            cond2 = wavelet_f_onset <= 98;

            [mx, cond3] = max(wmean);  % cond3 = scale index of max
            cond4 = mx > 0.08;

            % Peaks in aa1 within the segment
            [~, p_ind] = findpeaks(aa1(onsets(m):offsets(m)), ...
                                   'MinPeakDistance', 0.1*fs, ...
                                   'MinPeakHeight',  0.05);

            if cond1 && cond2 && cond4 && abs(cond3 - 90) <= 2 && numel(p_ind) >= 3
                if any(diff(p_ind)/fs > 0.15) && any(diff(p_ind)/fs < 0.3)
                    temp_ind(end+1) = m;
                    wmean_list{end+1} = wmean; 
                end
            end
        end
    end
end

onsets  = onsets(temp_ind);
offsets = offsets(temp_ind);

% ---------------- Package output ----------------
OUT = struct();
OUT.onsets      = onsets;
OUT.offsets     = offsets;
OUT.aa1         = aa1;
OUT.mask        = mask(:);
OUT.cfs         = cfs;
OUT.wmean_list  = wmean_list;
OUT.fs          = fs;

OUT.debug = struct();
OUT.debug.n_initial_segments = numel(keep);
OUT.debug.n_final_segments   = numel(onsets);
OUT.debug.threshold_band     = [85 90];
OUT.debug.band_thresh        = 0.04;
OUT.debug.wmean_thresh       = 0.05;
OUT.debug.mx_thresh          = 0.08;
OUT.debug.MinPeakDistance_s  = 0.1;
OUT.debug.MinPeakHeight      = 0.05;
OUT.debug.dur_range_s        = [0.6 3.5];
OUT.debug.interval_range_s   = [0.15 0.3];
OUT.debug.wavelet_params     = [3 25];

end
