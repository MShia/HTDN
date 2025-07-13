%% Modulation Classification over Fading Channels Using Hierarchical Deep Learning
% This script evaluates modulation classification accuracy using hierarchical CNNs
% with classification split into linear and nonlinear modulation types,
% followed by subgroup classification.

clear; clc;

%% ----------------------------- Parameter Setup -----------------------------
% Signal-to-Noise Ratio range
SNR = -18:3:12;  

% Modulation types (8-class problem)
modulationTypes = categorical(["2psk", "4psk", "8psk", "16qam", ...
                               "OQPSK", "GMSK", "GFSK", "CPFSK"]);

% Dataset size per sample
N_samples = 512;

% Monte Carlo iterations
NItr = 500;

% Doppler shifts (not used in this script, but included for completeness)
DS = 0:50:400;

% Fading channel parameters
SR = 1e-5;              % Symbol rate
PD = [0 1e-6 2e-6];     % Path delays
PG = [0 -3 -9];         % Path gains
taps = 3;               % Number of channel taps

% Classification network group count
nC = 8; 

% Initialize accuracy array
accuracy = zeros(1, length(SNR)); 

%% ---------------------------- Load Pre-trained Models ----------------------------

% Top-level classifier: Linear vs Nonlinear
OG     = load('Main_LinVsNonLin_1NOF_OrFlat128_NET');

% Linear Subgroup Classifier
MG     = load('Linear_SubGroup_1NOF_OrFS_OrFlat128_NET');
G1     = load('BPSK_QPSK_SubGroup_OrFlat128_NET');
G2     = load('8PSK_16QAM_SubGroup_OrFlat128_NET');

% Nonlinear Subgroup Classifier
MG_NL  = load('NonLinear_SubGroup_1NOF_OrFS_OrFlat128_NET');
G1_NL  = load('OQPSK_GMSK_SubGroup_OrFlat128_NET');
G2_NL  = load('GFSK_CPFSK_SubGroup_OrFlat128_NET');

%% ---------------------------- Classification Loop ----------------------------

for sn = 1:length(SNR)
    int_accuracy = zeros(NItr, length(modulationTypes)); % Per SNR accuracy
    
    for i = 1:NItr
        for x = 1:length(modulationTypes)
            acc = 0;
            
            % Generate data sample
            [Data_OG] = DataGen_AWGN_FS_2DCNN_Mixed(SNR(sn), 128, 1, 0, 'aw', 1, modulationTypes(x));

            % Step 1: Top-level classification - Linear vs Nonlinear
            YTest_OG = classify(OG.net, Data_OG);

            if (YTest_OG == categorical(0))  % Linear Modulation
                % Step 2a: Linear subgroup classification
                YTest = classify(MG.net, Data_OG);

                if (YTest == categorical(0))  % Subgroup: 2PSK, 4PSK
                    pred1 = classify(G1.net, Data_OG);
                    acc = (pred1 == categorical(x - 1));  % Classes: 0,1
                elseif (YTest == categorical(1))  % Subgroup: 8PSK, 16QAM
                    pred2 = classify(G2.net, Data_OG);
                    acc = (pred2 == categorical(x - 3));  % Classes: 0,1
                end

            elseif (YTest_OG == categorical(1))  % Nonlinear Modulation
                % Step 2b: Nonlinear subgroup classification
                YTest_NL = classify(MG_NL.net, Data_OG);

                if (YTest_NL == categorical(0))  % Subgroup: OQPSK, GMSK
                    pred_NL1 = classify(G1_NL.net, Data_OG);
                    acc = (pred_NL1 == categorical(x - 5));  % Classes: 0,1
                elseif (YTest_NL == categorical(1))  % Subgroup: GFSK, CPFSK
                    pred_NL2 = classify(G2_NL.net, Data_OG);
                    acc = (pred_NL2 == categorical(x - 7));  % Classes: 0,1
                end
            end

            % Store accuracy per iteration and modulation type
            int_accuracy(i, x) = acc;
        end
    end

    % Aggregate accuracy across iterations and modulation types
    accuracy(sn) = sum(sum(int_accuracy) / NItr) / nC;
end

%% ---------------------------- Plotting Results ----------------------------

figure;
plot(SNR, accuracy, 'b-o', 'LineWidth', 2); 
xlabel('SNR (dB)');
ylabel('Overall Classification Accuracy');
title('Modulation Classification Accuracy over SNR');
grid on;
legend('Hierarchical CNN Accuracy');
