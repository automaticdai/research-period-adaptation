% Discretized Controller Stability
% Author: Xiaotian Dai
%         University of York
% Note:
% This Program explors the scheduling effect (task period) to system
% stability. The program is the same as to explore the minimal sampling
% frequency of a system.

clear; clc; close all;

%% Parameters
T0 = 0.05;
step_times = 20;
step_changes = 0.01;
simout_sampling_time = 0.01;


%% System model
s = tf('s');
Gs = 1.0 / (s * s + 5 * s + 1);
Gcs = tf(40);
Hs = tf(1);


%% reference performance (continous controller)
sim('c2d_controller_continuous')
subplot(2,2,[1 2])
plot(simout.time, simout.Data, '-')
hold on;


%% discretrized performance
data_len = 20 / simout_sampling_time + 1;
x = 1: data_len;
data = zeros(step_times, data_len);

for i = 1:step_times
    % construct system model
    Ts = T0 + step_changes * i;
    Hz = c2d(Hs, Ts, 'zoh');
    Gz = c2d(Gs, Ts, 'zoh');
    Gcz = c2d(Gcs, Ts, 'zoh');
    
    % closed-loop transfer function
    % GH(s) = G(s) / (1+H(s)*G(s))
    GHz = (Gcz * Gz) / (1 + Hz * Gz * Gcz);
    
    % calculate and plot poles
    disp(Ts);
    disp(abs(pole(GHz)));
    
    subplot(2,2,3)
    pzplot(GHz)
    axis([-1.5 1.5 -1.5 1.5])
    
    % simulate system response
    sim('c2d_controller')
    subplot(2,2,[1 2])
    plot(simout.time, simout.Data)
    data(i,:) = simout.Data;
    
    % plot response error
    subplot(2,2,4)
    error = sum((simout.Data - 1) .^ 2, 2);
    plot(x .* simout_sampling_time, error)

    pause(1.0)
end

figure;
surf(data)

figure;
error = sum((data - 1) .^ 2, 2);
plot(error)
title('Control error v.s. sampling period')
