% Task 3

clear;
close all;
clc;

% Simulation parameters
numTransmitBits = 10^6; % Number of bits to transmit
SNR_dB = 0:10; % SNR range from 0 to 10 dB
M = 4; % Maximum number of taps in equalizers used

% Pre-allocate the error matrix
errors = zeros(M+1, length(SNR_dB)); % Rows for different equalizers, columns for SNR values

% Transmitter
bits = rand(1, numTransmitBits) > 0.5; % Random bit generation
BPSK = 2*bits - 1; % BPSK modulation (0 mapped to -1, 1 mapped to 1)

% Define the multipath channel
numTaps = 3;
channelTaps = [0.3, 0.9, 0.4];
channelOutput = conv(BPSK, channelTaps);

for i = 1:length(SNR_dB)
    % Apply AWGN to the channel output
    noisyOutput = awgn(channelOutput, SNR_dB(i), 'measured');

    for k = 1:M
        % Construct the diagonal matrix for equalizer
        equalizerMatrix = toeplitz([channelTaps(2:end), zeros(1, 2*k+1-numTaps+1)], ...
            [channelTaps(2:-1:1), zeros(1, 2*k+1-numTaps+1)]);
        targetImpulse = zeros(1, 2*k+1);
        targetImpulse(k+1) = 1; % Target impulse response
        equalizerCoeffs = equalizerMatrix \ targetImpulse'; % Least squares solution for equalizer coefficients

        % Filter the noisy output with the equalizer
        equalizedOutput = conv(noisyOutput, equalizerCoeffs);
        equalizedOutput = equalizedOutput(k+2:end); % Compensate for filter delay

        % Sample and decode
        decodedBits = real(equalizedOutput(1:numTransmitBits)) > 0;

        % Count the errors
        errors(k+1, i) = sum(bits ~= decodedBits);
    end
end

% Additional AWGN channel processing without multipath
for i = 1:length(SNR_dB)
    awgnOutput = awgn(BPSK, SNR_dB(i));
    decodedBitsAWGN = real(awgnOutput(1:numTransmitBits)) > 0;
    errors(1, i) = sum(bits ~= decodedBitsAWGN);
end

% Calculate Bit Error Rate (BER)
simulatedBER = errors / numTransmitBits;

% Plot BER vs SNR for different equalizers
figure;
semilogy(SNR_dB, simulatedBER(2,:), 'bs-', 'Linewidth', 1); hold on;
semilogy(SNR_dB, simulatedBER(3,:), 'gd-', 'Linewidth', 1);
semilogy(SNR_dB, simulatedBER(4,:), 'ks-', 'Linewidth', 1);
semilogy(SNR_dB, simulatedBER(5,:), 'mx-', 'Linewidth', 1);
semilogy(SNR_dB, simulatedBER(1,:), 'rx-', 'Linewidth', 1);
axis([0 10 10^-3 0.5]);
grid on;
legend('ZF 3-tap', 'ZF 5-tap', 'ZF 7-tap', 'ZF 9-tap', 'AWGN only');
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate');
title('BER vs. Eb/N0 for BPSK in ISI with ZF Equalization');
