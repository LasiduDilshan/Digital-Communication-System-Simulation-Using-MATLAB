%Task 3 - ZF Equalizer Effect on Eye-Diagram

clear;
close all;
clc;

% Initializing the needed parameters
samp_freq = 100;
no_trans_bits = 10^3;
time = 0:1/samp_freq:999/samp_freq;
t = -samp_freq:1/(samp_freq):samp_freq;

% Creating 0,1ly and converting them to 1,-1
BPSK = 2*(rand(1,no_trans_bits)>0.5)-1;

% Sinc function
Sinc = sinc(t);

% Upsampling the BPSK impulse array to adjust to the sampling frequency
N = length(BPSK);
upsampleFactor = 100; % Since you are appending 99 zeros after each BPSK element

% Pre-allocate BPSK_U with the correct size
BPSK_U = zeros(1, N * upsampleFactor);

% Index to keep track of the insertion point in BPSK_U
index = 1;

% Loop through each element in BPSK
for i = 1:N
    BPSK_U(index) = BPSK(i);  % Insert the BPSK value
    index = index + upsampleFactor; % Increment index by 100 to skip 99 zeros
end

time_u = 0:1/samp_freq:99999/samp_freq;

% Transmitter
bits = rand(1, no_trans_bits) > 0.5; % Random bit generation
BPSK = 2*bits - 1; % BPSK modulation (0 mapped to -1, 1 mapped to 1)

% Define the multipath channel
numTaps = 3;
channelTaps = [0.3, 0.9, 0.4];
channelOutput = conv(BPSK, channelTaps);

for k = 1:4
    % Construct the diagonal matrix for equalizer
    equalizerMatrix = toeplitz([channelTaps(2:end), zeros(1, 2*k+1-numTaps+1)], ...
        [channelTaps(2:-1:1), zeros(1, 2*k+1-numTaps+1)]);
    targetImpulse = zeros(1, 2*k+1);
    targetImpulse(k+1) = 1; % Target impulse response
    equalizerCoeffs = equalizerMatrix \ targetImpulse'; % Least squares solution for equalizer coefficients

    % Filter the output with the equalizer
    equalizedOutput = conv(channelOutput, equalizerCoeffs);
    equalizedOutput = equalizedOutput(k+2:end); % Compensate for filter delay

    % Upsampling the BPSK impulse array to adjust to the sampling frequency
    N = length(BPSK);
    upsampleFactor = 100; % Since you are appending 99 zeros after each BPSK element

    % Pre-allocate BPSK_U with the correct size
    BPSK_U = zeros(1, N * upsampleFactor);
 
    % Index to keep track of the insertion point in BPSK_U
    index = 1;

    % Loop through each element in BPSK
    for i = 1:N
        BPSK_U(index) = equalizedOutput(i);  % Insert the BPSK value
        index = index + upsampleFactor; % Increment index by 100 to skip 99 zeros
    end

    sinc_draw = conv(Sinc,BPSK_U,'same');
    
    % Plotting the eye diagram for Sinc pulse transmission
    eyediagram(sinc_draw, 2*samp_freq);
    title(sprintf('Eye Diagram for Sinc Pulse at M = %d ', k));
    xlabel('Time');
    ylabel('Amplitude');
    axis([-0.5 0.5 -2.4 2.2]);
    grid on;

end