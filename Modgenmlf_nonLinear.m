function txSig = Modgenmlf_nonLinear(m, N)
% Modgenmlf_nonLinear generates modulated signals for various schemes.
%
% INPUTS:
%   m - Modulation scheme (e.g., '2psk', '4qam', 'GMSK', etc.)
%   N - Number of symbols (or bits, depending on scheme)
%
% OUTPUT:
%   txSig - Modulated signal (row vector)

% Ensure reproducibility (you may change to fixed seed if desired)
rng shuffle;

% Initialize output
txSig = [];

switch lower(m)
    %% ----------------- PSK MODULATIONS -----------------
    case '2psk'
        M = 2;
        data = randi([0 M-1], N, 1);
        txSig = pskmod(data, M, pi/M, 'gray')';
        
    case '4psk'
        M = 4;
        data = randi([0 M-1], N, 1);
        txSig = pskmod(data, M, pi/M, 'gray')';
        
    case '8psk'
        M = 8;
        data = randi([0 M-1], N, 1);
        txSig = pskmod(data, M, pi/M, 'gray')';
        
    case '16psk'
        M = 16;
        data = randi([0 M-1], N, 1);
        txSig = pskmod(data, M, pi/M, 'gray')';
        
    %% ----------------- ASK & FSK -----------------
    case 'ask'
        % You must define the ask_fsk() function separately
        txSig = ask_fsk(N);
        
    %% ----------------- QAM MODULATIONS -----------------
    case '2qam'
        M = 2;
        k = log2(M);
        dataIn = randi([0 1], N, 1);
        dataSymbolsIn = bi2de(reshape(dataIn, [], k));
        txSig = qammod(dataSymbolsIn, M, 'gray')';
        
    case '4qam'
        M = 4;
        k = log2(M);
        dataIn = randi([0 1], N, 1);
        dataSymbolsIn = bi2de(reshape(dataIn, [], k));
        txSig = (1/sqrt(2)) * qammod(dataSymbolsIn, M, 'gray')';
        
    case '16qam'
        M = 16;
        k = log2(M);
        dataIn = randi([0 1], N*4, 1); % More bits for higher order
        dataSymbolsIn = bi2de(reshape(dataIn, [], k));
        txSig = (1/sqrt(10)) * qammod(dataSymbolsIn, M, 'gray')';
        
    %% ----------------- OTHER DIGITAL MODULATIONS -----------------
    case 'msk'
        sps = 8;                         % Samples per symbol
        data = randi([0 1], N/sps, 1);   % Number of bits
        txSig = mskmod(data, sps, [], pi/2)'; 
        
    case 'gmsk'
        modObj = comm.GMSKModulator('BitInput', true, 'InitialPhaseOffset', pi/4);
        data = randi([0 1], N/8, 1);
        txSig = modObj(data)';
        
    case 'oqpsk'
        modObj = comm.OQPSKModulator('BitInput', true);
        data = randi([0 1], N/2, 1);
        txSig = modObj(data)';
        
    case 'gfsk'
        modObj = comm.CPMModulator('ModulationOrder', 2, 'FrequencyPulse', 'Gaussian', ...
            'BandwidthTimeProduct', 0.5, 'ModulationIndex', 1, ...
            'BitInput', true);
        data = randi([0 1], N/modObj.SamplesPerSymbol, 1);
        txSig = modObj(data)';
        
    case 'cpfsk'
        modObj = comm.CPFSKModulator(16, 'BitInput', true, ...
            'SymbolMapping', 'Gray');
        data = randi([0 1], N/2, 1);
        txSig = modObj(data)';
        
    otherwise
        error('Unsupported modulation type: %s', m);
end
end
