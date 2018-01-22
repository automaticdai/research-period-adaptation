clear; clc; close all;

global t; 
global y;

load('matlab.mat')

y1 = y(:,1);

Ts = 0.001;
T = 0.001;
cost_max = 0.6;
confidence = 1.0;
reward = 0;
penalty = 0;

subplot(2,1,1)
plot(t, y1);
hold on; 

% initial point
cost = period_to_cost_map(T, t, y1);
scatter(T, cost)
title('Input-Cost Mapping')

% first trial
T = T + 0.0010;
cost = period_to_cost_map(T, t, y1);
reward = cost_max - cost;
penalty = 0;

i = 0;
while true
    % make action
    T = T + Ts * floor(0.02 * reward /Ts);
    
    % get cost
    cost = period_to_cost_map(T, t, y1);
    subplot(2,1,1)
    scatter(T, cost, 'filled');
    hold on;
    
    % reward function
    reward = cost_max - cost;
    penalty = 0;
    subplot(2,1,2)
    scatter(i, reward, 'rx');
    title('Reward function')
    hold on;
    
    pause(1)
    i = i + 1;
end
