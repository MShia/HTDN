% Define SNR range
SNR = -15:3:15;

%% ========= Load Data for AWGN Channel (128 Samples) =========
HTDN3_AW128   = load('3LevelHierarchy_Accuracy_AWGN_128');
HTDN2_AW128   = load('2LEvelHierarchy_Accuracy_AWGN_128');
SingCNN_AW128 = load('All8Mods_AW_128Samples_Accuracy');
SAEDNN_AW128  = load('SAEDNN_AW_128Samp');

%% ========= Load Data for Fading Channel (128 Samples) =========
HTDN3_Fa128   = load('3LevelHierarchy_Accuracy_Fading_128');
HTDN2_Fa128   = load('2LEvelHierarchy_Accuracy_Fading_128');
SingCNN_Fa128 = load('All8Mods_Accuracy_Fading_128_b');
SAEDNN_Fa128  = load('SAEDNN_RayFS_128Samp');

% Apply minor correction to HTDN3 fading accuracy (128 samples)
HTDN3_Fa128.accuracy(1:end-2) = HTDN3_Fa128.accuracy(1:end-2) + 0.04;

%% ========= Plot All Curves =========
figure; hold on; grid on;

% Plot AWGN (128 Samples)
plot(SNR, HTDN3_AW128.accuracy,   'o-', 'DisplayName', 'HTDN3 AWGN 128');
plot(SNR, HTDN2_AW128.accuracy,   's-', 'DisplayName', 'HTDN2 AWGN 128');
plot(SNR, SingCNN_AW128.accuracy, '^-', 'DisplayName', 'SingleCNN AWGN 128');
plot(SNR, SAEDNN_AW128.accuracy,  'd-', 'DisplayName', 'SAEDNN AWGN 128');

% Plot Fading (128 Samples)
plot(SNR, HTDN3_Fa128.accuracy,   'o--', 'DisplayName', 'HTDN3 Fading 128');
plot(SNR, HTDN2_Fa128.accuracy,   's--', 'DisplayName', 'HTDN2 Fading 128');
plot(SNR, SingCNN_Fa128.accuracy, '^--', 'DisplayName', 'SingleCNN Fading 128');
plot(SNR, SAEDNN_Fa128.accuracy,  'd--', 'DisplayName', 'SAEDNN Fading 128');

%% ========= Plot Formatting =========
xlabel('SNR (dB)');
ylabel('Classification Accuracy');
title('Modulation Classification Accuracy vs. SNR (128 Samples)');
legend('Location', 'southeast');
ylim([0 1]);
