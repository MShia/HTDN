function [Data, Label] = DataGen_AWGN_FS_2DCNN_Mixed(SNR, SL, it, DS, ch, NoF, ~)
% Generate dataset for 2D CNN input with multiple modulation types under AWGN or FS fading.
%
% Inputs:
%   SNR   - Vector of SNR values in dB (e.g., [0 5 10])
%   SL    - Signal Length (e.g., 512)
%   it    - Number of Monte Carlo Iterations (N)
%   DS    - Doppler shift (used in FS fading)
%   ch    - Channel type: 'aw' for AWGN, 'fs' for Fading
%   NoF   - Number of subframes/features per iteration
%   ~     - (Unused input, previously MT)
%
% Outputs:
%   Data  - [SL x 2 x NoF x TotalSamples] data array (real/imag format)
%   Label - Corresponding categorical labels for modulation types

% ------- Channel & System Parameters -------
SR = 1e-5;                           % Symbol Rate
PD = [0 1e-6 2e-6];                  % Path Delays (s)
PG = [0 -3 -9];                      % Path Gains (dB)
mod_types = {'2psk','4psk','8psk','16qam','OQPSK','GMSK','GFSK','CPFSK'};
nC = numel(mod_types);              % Number of modulation classes
N = it;                             
AcFea = SL;
total_samples = numel(SNR) * N * nC;

% ------- Preallocate Output Arrays -------
Data = zeros(AcFea, 2, NoF, total_samples);
Label = zeros(1, total_samples);

% ------- Main Loop: SNR -> Iteration -> Modulation -------
for sn = 1:length(SNR)
    for m = 1:N
        for e = 1:NoF
            for mod_id = 1:nC
                % --- Generate baseband signal ---
                mod_type = mod_types{mod_id};
                sig = Modgenmlf_nonLinear(mod_type, SL);

                % --- Apply channel ---
                if strcmp(ch, 'aw')
                    ray = 1;  % (set to 1; may replace with Rayleigh envelope if desired)
                    rx_sig = awgn(ray * sig, SNR(sn))';
                elseif strcmp(ch, 'fs')
                    rx_sig = RayFSchannel(sig, SR, DS, PD, PG, SNR(sn));
                    rx_sig = rx_sig';  % Transpose to match real/imag stacking
                else
                    error('Unsupported channel type: use ''aw'' or ''fs''');
                end

                % --- Format data into [real, imag] ---
                sample_idx = (sn-1)*N*nC + (mod_id-1)*N + m;
                Data(:, :, e, sample_idx) = [real(rx_sig), imag(rx_sig)];
                Label(sample_idx) = mod_id - 1;
            end
        end
    end
end

% Convert to categorical labels
Label = categorical(Label);
end
