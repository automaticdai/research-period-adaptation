clear; clc; close all;

% Gp1 = 1 / (s + 1);
filename = 'cost_ideal.mat';
myVars = {'t','y'};
S0 = load(filename, myVars{:});

% Gp2 = 1.2 / (0.9 * s + 0.8);
filename = 'cost_actual.mat';
myVars = {'t','y'};
S1 = load(filename, myVars{:});

%plot(S0.y(:,1), S0.y(:,2), 'x-');
%hold on;
%plot(S1.y(:,1), S1.y(:,2), 'x-');


plot(S0.t, S0.y(:,1), 'x-'); hold on
plot(S1.t, S1.y(:,1), 'x-');
input()







global t; 
global y;

load('cost_actual.mat')

y1 = y(:,1);

Ts = 0.001;
T = 0.01;
cost_max = 0.08;
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

state_i = 0;
while true
    % make action
    T = T + 0.0010;
    
    % get cost
    cost = period_to_cost_map(T, t, y1);
    subplot(2,1,1)
    scatter(T, cost, 'filled');
    hold on;
    
    % reward function
    reward = cost_max - cost;
    penalty = 0;
    subplot(2,1,2)
    scatter(state_i, reward, 'rx');
    title('Reward function')
    hold on;
    
    pause(1)
    state_i = state_i + 1;
    
    % 
    if (cost > cost_max)
        break;
    end
end
