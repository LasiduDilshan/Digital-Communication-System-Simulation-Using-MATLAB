%Task 3 - Multipath Effect on Eye-Diagrams

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

% Define the multipath channel
numTaps = 3;
channelTaps = [0.3, 0.9, 0.4];
channelOutput = conv(BPSK, channelTaps);

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
    BPSK_U(index) = channelOutput(i);  % Insert the BPSK value
    index = index + upsampleFactor; % Increment index by 100 to skip 99 zeros
end

time_u = 0:1/samp_freq:99999/samp_freq;
% Plotting the upsampled BPSK Impulse train
figure;
stem(time_u, BPSK_U);
xlabel('Time');
ylabel('Amplitude');
title('BPSK Upsampled impulse train');
axis([0 5 -1.2 1.2]);
grid on;

% Plotting the diagram for impulse train convolved with sinc pulse
figure;
sinc_draw = conv(Sinc,BPSK_U,'same');
plot(t,sinc_draw);
title('Impulse train convolved with Sinc pulse');
xlabel('Time');
ylabel('Amplitude');
axis([0 30 -2 2]);
grid on;

% Plotting the eye diagram for Sinc pulse transmission
eyediagram(sinc_draw, 2*samp_freq);
title('Eye diagram for Sinc pulse');
xlabel('Time');
ylabel('Amplitude');
axis([-0.5 0.5 -2.4 2.2]);
grid on;

% Developing the raised cosine with 0.5 roll-off
roll_off = 0.5;
cos_num = cos(roll_off*pi*t);
cos_den = (1 - (2 * roll_off * t).^2);
cos_denzero = abs(cos_den)<10^-10;
Raised_cosine = cos_num./cos_den;
Raised_cosine(cos_denzero) = pi/4;
rc_roll5 = Sinc.*Raised_cosine;

% Plotting the raised cosine with roll off 0.5
figure;
plot(t,rc_roll5);
title('Raised cosine Pulse shape with 0.5 roll-off');
xlabel('Time');
ylabel('Amplitude');
axis([-10 10 -1 1.2]);
grid on;

% Plotting the diagram for impulse train convolved with raised cosine pulse of 0.5 roll-off factor
figure;
rc_roll5_draw = conv(rc_roll5,BPSK_U,'same');
plot(t,rc_roll5_draw);
title('Impulse train convolved with raised cosine pulse with roll-off 0.5');
xlabel('Time');
ylabel('Amplitude');
axis([0 30 -2 2]);

% Plotting the eye diagram for raised cosine pulse with 0.5 roll-off transmission
eyediagram(rc_roll5_draw,2*samp_freq);
title('Eye diagram with raised cosine pulse with 0.5 roll-off');
xlabel('Time');
ylabel('Amplitude');
axis([-0.5 0.5 -2.4 2.2]);
grid on;

% Developing the raised cosine with 1 roll-off
roll_off = 1;
cos_num = cos(roll_off*pi*t);
cos_den = (1 - (2 * roll_off * t).^2);
cos_denzero = abs(cos_den)<10^-10;
Raised_cosine = cos_num./cos_den;
Raised_cosine(cos_denzero) = pi/4;
rc_roll_1 = Sinc.*Raised_cosine;

% Plotting the raised cosine with roll off 1
figure;
plot(t,rc_roll_1);
title('Raised cosine Pulse shape with 1 roll-off');
xlabel('Time');
ylabel('Amplitude');
axis([-10 10 -1 1.2]);
grid on;

% Plotting the diagram for impulse train convolved with raised cosine pulse of 1 roll-off factor
figure;
rc_roll1_draw = conv(rc_roll_1,BPSK_U,'same');
plot(t,rc_roll1_draw);
title('Impulse train convolved with raised cosine pulse with roll-off 1');
xlabel('Time');
ylabel('Amplitude');
axis([0 30 -2 2]);

% Plotting the eye diagram for raised cosine pulse with 1 roll-off transmission
eyediagram(rc_roll1_draw, 2*samp_freq);
title('Eye diagram with raised cosine pulse with 1 roll-off');
xlabel('Time');
ylabel('Amplitude');
axis([-0.5 0.5 -2.4 2.2]);
grid on;

% Task 2

SNR=10; %given SNR
power_noise= 1./(10.^(0.1*SNR));
%generating AWGN noise
sinc_conv=conv(Sinc,BPSK_U,'same');
noise =((power_noise/2)^0.5)*randn(1,length(sinc_conv));
sinc_noise=sinc_conv+noise;

% Plotting the convolved sinc pulse with noise
figure;
plot(t,sinc_noise(1:20001));
title('Sinc pulses with noise');
xlabel('Time');
ylabel('Amplitude');
axis([0 30 -2 2]);
grid on;

% Drawing the eye diagram for sinc pulse with noise
eyediagram(sinc_noise, samp_freq*2);
title('Eye diagram for sinc pulses with noise');
xlabel('Time');
ylabel('Amplitude');
axis([-0.5 0.5 -2.4 2.2]);
grid on;

% Adding the noise to the convoluted raised cosine pulse with 0.5 roll-off
rc_roll5_conv = conv(rc_roll5,BPSK_U,'same');
rc_5_noise=rc_roll5_conv+noise;

% Plotting the convolved raised cosine pulse of 0.5 roll-off with noise
figure;
plot(t,rc_5_noise(1:20001));
title('Impulse train convolved with raised cosine of 0.5 roll-off pulse with noise');
xlabel('Time');
ylabel('Amplitude');
axis([0 30 -2 2]);
grid on;

% Drawing the eye diagram for raised cosine pulse of 0.5 roll-off with noise
eyediagram(rc_5_noise, samp_freq*2);
title('Eye diagram with raised cosine pulse with 0.5 roll-off with noise');
xlabel('Time');
ylabel('Amplitude');
axis([-0.5 0.5 -2.4 2.2]);
grid on;

% Adding the noise to the convoluted raised cosine pulse with 1 roll-off
rc_roll1_conv = conv(rc_roll_1,BPSK_U,'same');
rc_1_noise=rc_roll1_conv+noise;

% Plotting the convolved raised cosine pulse of 1 roll-off with noise
figure;
plot(t,rc_1_noise(1:20001));
title('Impulse train convolved with raised cosine of 1 roll-off pulse with noise');
xlabel('Time');
ylabel('Amplitude');
axis([0 30 -2 2]);
grid on;

% Drawing the eye diagram for raised cosine pulse of 1 roll-off with noise
eyediagram(rc_1_noise, 2*samp_freq);
title('Eye diagram with raised cosine pulse with 1 roll-off with noise');
xlabel('Time');
ylabel('Amplitude');
axis([-0.5 0.5 -2.4 2.2]);
grid on;