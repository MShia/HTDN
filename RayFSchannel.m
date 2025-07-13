function rxSig = RayFSchannel(txSig, SR, DS, PD, PG, snr)
% RayFSchannel applies a frequency-selective Rayleigh fading channel
% followed by additive white Gaussian noise (AWGN) to the input signal.
%
% INPUTS:
%   txSig - Transmitted signal (vector)
%   SR    - Sample rate (Hz)
%   DS    - Maximum Doppler shift (Hz)
%   PD    - Path delays (vector, in seconds)
%   PG    - Average path gains (vector, in dB)
%   snr   - Signal-to-noise ratio (in dB)
%
% OUTPUT:
%   rxSig - Received signal after Rayleigh fading and AWGN

% Create Rayleigh fading channel object
rchan = comm.RayleighChannel( ...
    'SampleRate',           SR, ...               % Sampling rate
    'PathDelays',           PD, ...               % Delay profile
    'AveragePathGains',     PG, ...               % Power profile
    'NormalizePathGains',   true, ...             % Normalize to preserve average power
    'MaximumDopplerShift',  DS, ...               % Doppler shift
    'PathGainsOutputPort',  true);                % Output path gains (not used here)

% Apply fading to the signal
% Note: txSig must be a column vector
fadedSig = rchan(txSig(:));  % Ensure column format

% Add AWGN noise at specified SNR
rxSig = awgn(fadedSig, snr);

end
