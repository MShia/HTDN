%% Hierarchical CNN-Based Modulation Classification Over Fading Channel
% This script performs hierarchical classification of modulation schemes
% over an AWGN channel using pretrained CNN models. It distinguishes between
% linear and nonlinear modulations, then uses appropriate subgroup models.

clear; clc;

%% ------------------------ Parameter Definitions ------------------------

% Doppler Shift values (not used in current logic, but defined)
DS = 0:50:400;

% SNR range in dB
SNR = -16:3:14;

% Modulation types (8-class hierarchical classification)
modulationTypes = categorical(["2psk", "4psk", "8psk", "16qam", ...
                                "OQPSK", "GMSK", "GFSK", "CPFSK"]);

% Number of samples in each input signal
N_samples = 512;

% Number of Monte Carlo Iterations
NItr = 500;

% Number of total classes
nC = 8;

% Fading Channel Parameters (symbol rate, path delays, and gains)
SR = 1e-5;                  % Symbol Rate (unused here, placeholder)
PD = [0 1e-6 2e-6];         % Path Delays
PG = [0 -3 -9];             % Path Gains
taps = 3;                   % Channel taps (not used directly)

% Initialize accuracy output
accuracy = zeros(1, length(SNR));

%% ------------------------ Load Pretrained Models ------------------------

% Top-level classifier: Linear vs Nonlinear
OG = load('Main_LinVsNonLin_1NOF_OrFlat128_NET');

% Linear Modulation Subgroup Model (2PSK, 4PSK, 8PSK, 16QAM)
G1 = load('Linear_FlatFadTestRaw_128_NET');

% Nonlinear Modulation Subgroup Model (OQPSK, GMSK, GFSK, CPFSK)
G2 = load('NonLinear_FlatFadTestRaw_128_NET');

%% ------------------------ Classification Loop ------------------------

for sn = 1:length(SNR)
    int_accuracy = zeros(NItr, length(modulationTypes)); % Initialize intermediate accuracy

    for i = 1:NItr
        for x = 1:length(modulationTypes)
            acc = 0;

            % Generate one signal sample with given SNR and modulation type
            Data_OG = DataGen_AWGN_FS_2DCNN_Mixed(SNR(sn), 128, 1, 0, 'aw', 1, modulationTypes(x));

            % Step 1: Linear vs Nonlinear Classification
            YTest_OG = classify(OG.net, Data_OG);

            if (YTest_OG == categorical(0))  % Linear Modulation
                % Step 2a: Classify within linear modulations (first 4 classes)
                pred1 = classify(G1.net, Data_OG);
                acc = (pred1 == categorical(x - 1));  % class indices: 0 to 3

            elseif (YTest_OG == categorical(1))  % Nonlinear Modulation
                % Step 2b: Classify within nonlinear modulations (last 4 classes)
                pred_NL1 = classify(G2.net, Data_OG);
                acc = (pred_NL1 == categorical(x - 5));  % class indices: 0 to 3
            end

            % Store classification result for this iteration and modulation type
            int_accuracy(i, x) = acc;
        end
    end

    % Average classification accuracy across all modulation types and trials
    accuracy(sn) = sum(sum(int_accuracy) / NItr) / nC;
end

%% ------------------------ Plotting Results ------------------------

figure;
plot(SNR, accuracy, 'r-o', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('Classification Accuracy');
title('Hierarchical Modulation Classification Accuracy over SNR');
grid on;
legend('Hierarchical CNN');
