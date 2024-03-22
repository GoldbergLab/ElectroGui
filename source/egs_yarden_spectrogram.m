function [S,F,T,P] = mt_spectrogram(ax, sig_in,samplerate,time_step_ms,varargin)
        switch spectrogram_type
            case 'regular'
                [S,F,T,P] = spectrogram(sig_in,220,220-44,512,settings_params.FS);
                return
            
            otherwise
                % will use Slepian tapers
                NW = 4;
                nfft = 1024;
                
                nparams=length(varargin);
                for i_ind=1:2:nparams
	                switch lower(varargin{i_ind})
		                case 'nw'
                            NW = varargin{i_ind+1};
                        case 'nfft'
                            nfft = varargin{i_ind+1};
                    end
                end
                noverlap = nfft - round(time_step_ms/1000*samplerate);
                if noverlap < 0
                    disp('overlap cannot be negative');
                    return
                end
                [E,V] = dpss(nfft,NW);
                [S1,F,T] = spectrogram(sig_in,E(:,1),noverlap,nfft,samplerate);
                [S2,F,T] = spectrogram(sig_in,E(:,2),noverlap,nfft,samplerate);
                S = S1.*conj(S1)+S2.*conj(S2);
                dx = -real(S1.*conj(S2));
                dy = real(1i*(S1.*conj(S2)));
                fm = atan(max(dx(F>=settings_params.fmin))./max(dy(F>=settings_params.fmin))+eps);
                P = repmat(cos(fm),length(F),1).*dx + repmat(sin(fm),length(F),1).*dy;
        end
    end