function speccorr=vg_SpecCrossCorr(signal1,signal2, fs,bplot1,durmatch)
Fs=fs;

%signal1 and signal2 are the raw voltage waveforms of the two syllables you are comparing. 

%I only computed spec xcorrs on syllables that were of similar duration.
%The durmatch parameter specifies how similar in duration the two syllables
%must be

%windowFilt and NFFTfilt will affect your xcorr value by setting how
%course/fine your spectrogram will be.

windowFilt=8;%usually 5;%amt to divide 512 by in specifying windowsize;
NFFTfilt=2;%amt to divide 1024 by in setting Hz resolution;

bfiltsbs=1;%a logical parameter specifying if you want to smooth and/or subsample the spectrogram

%This function cross correlates two spectrograms.
if abs(length(signal1)-length(signal2))<durmatch*fs;
    
    freqRange = [500,7500];
    
    ud.startndx = 1;
    ud.endndx = min([length(signal1) length(signal2)]);
    
    startTime = 0;
    nCourse = 1;
    cLimits = [];
    windowSize = round(512/windowFilt);
    NFFT = 1024;
    
    %Determine the size of the axis... to determine the
    ud.ax = gca;
    ud.nCourse = nCourse; %sets the resolution I believe
    ud.windowSize = windowSize;
    ud.NFFT = NFFT;
    
    ud.Fs = Fs;
    ud.startTime = startTime;
    ud.freqRange = freqRange;
    ud.cLimits = cLimits;
    
    set(ud.ax, 'UserData', ud);
    set(ud.ax, 'ButtonDownFcn', @buttondown_quickspectrogram);
    
    persistent e;
    
    windowSize = ud.windowSize;
    windowSize = min(windowSize, ud.endndx - ud.startndx);
    NFFT = round(ud.NFFT/NFFTfilt);  %greater freq precision can be achieved by increasing this.
    
    %determine size of axis relative to size of the signal,
    %use this to adapt the window overlap and downsampling of the signal.
    %no need to worry about size of fftwindow, this doesn't effect speed.
    set(ud.ax,'Units','pixels')
    pixSize = get(ud.ax,'Position');
    numPixels = pixSize(3) / ud.nCourse;
    numWindows = (ud.endndx - ud.startndx) / windowSize;
    for bSignal1=[0 1];
        if bSignal1;
            ud.signal = signal1;
        else
            ud.signal=signal2;
        end
        
        if(numWindows < numPixels)
            %If we have more pixels, then ffts, then increase the overlap
            %of fft windows accordingly.
            ratio = ceil(numPixels/numWindows);
            windowOverlap = min(.999, 1 - (1/ratio));
            windowOverlap = floor(windowOverlap*windowSize);
            sss = ud.signal(ud.startndx:ud.endndx);
            Fs = ud.Fs;
        else
            %If we have more ffts then pixels, then we can do things, we can
            %downsample the signal, or we can skip signal between ffts.
            %Skipping signal mean we may miss bits of song altogether.
            %Decimating throws away high frequency information.
            ratio = floor(numWindows/numPixels);
            windowOverlap = -1*ratio;
            windowOverlap = floor(windowOverlap*windowSize);
            sss = ud.signal(ud.startndx:ud.endndx);
            Fs = ud.Fs;
            %windowOverlap = 0;
            %sss = decimate or downsample(ud.signal(ud.startndx:ud.endndx), ratio);
            %Fs = ud.Fs / ratio;
        end
        
        %Compute the spectrogram
        if(size(e,1) ~= windowSize)
            if(windowSize>2)
                [e] = dpss(windowSize,1);
            else
                return;
            end
        end
        [S,F,T,P] = spectrogram(sss,e(:,1),windowOverlap,NFFT,Fs);
        
        ndx = find((F>=ud.freqRange(1)) & (F<=ud.freqRange(2)));
        spec1=10*log10(abs(S(ndx,:))+.02);
        %Draw the spectrogram
        
        if bfiltsbs;
            sbs=1;%subsample in time;
            %use an image filter to smooth the spectrogram
            h=ones(1,25);spec1=imfilter(spec1,h,'symmetric');
            spec1=spec1(:,1:sbs:end);%
            sigspec{bSignal1+1}=reshape(spec1',numel(spec1),1);
        else
            sigspec{bSignal1+1}=reshape(spec1',numel(spec1),1);
        end
        if bplot1
            figure;
            imagesc(T+ud.startTime + (ud.startndx-1)/ud.Fs,F(ndx),spec1);
            axis xy; axis tight; colormap(jet);
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');
            set(ud.ax,'Units','normalized')
            set(ud.ax, 'UserData', ud);
            set(ud.ax, 'ButtonDownFcn', @buttondown_quickspectrogram);
        end
 
    end
    speccorr=xcov(sigspec{1},sigspec{2},0,'coeff');
    %figure;plot(sigspec{1},sigspec{2},'r');
else
    speccorr=[];
end