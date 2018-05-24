% -------------------------------------------------------------------------
% mpc_period_with_abitary_reference.m
% Explore MPC performance with period.
% Author: Xiaotian Dai
% https://uk.mathworks.com/help/mpc/examples/control-of-a-single-input-single-output-plant.html
% -------------------------------------------------------------------------

close all;
addpath('./afbs-kernel/')
addpath('./afbs-kernel/core')
addpath('./toolbox/')

global g_TaskPeriod;
g_TaskPeriod = 0.019;


%% Compile the Kernel
cd('afbs-kernel')
mex -g ./core/kernel.cpp ./core/afbs.cpp ./core/app.cpp ./core/utils.cpp ...
       ./core/task.cpp
cd('..')


%% Simulation parameters
simu.time = 5;
simu.sampling_time = 100 * 10^-6;    % 100 us


%% System dynamic model
% first-order system
% period should be 5% - 10% of the rising time (settling time for 1st order systems)
% settling time = 4 * tau
%tau = 0.1;
%plant = tf([10],[tau 1]);

% second-order system
plant.sys = zpk([],[-10+10j -10-10j],100);
plant.model_ss = ss(plant.sys);
plant.order = order(plant.sys);
plant.bwcl = bandwidth(feedback(plant.sys, 1));

plant.noise_level = 0;
plant.disturbance_on = 0;

A = plant.model_ss.a;
B = plant.model_ss.b;
C = plant.model_ss.c;
D = plant.model_ss.d;

% LQR controller
Q = 1 * eye(plant.order);
R = 0.1;
N = zeros(plant.order, 1);

%[K,S,E] = lqrd(A, B, Q, R, N, 0.010);
[K,S,E] = lqr(A, B, Q, R, N);
%N_bar = (-1 * C * (A - B * K - 1)^(-1) * B) ^ (-1);
N_bar = rscale(A, B, C, D, K);
ctrl.K = K;
ctrl.N_bar = N_bar;


%% External signals
% references
t = [0:simu.sampling_time:simu.time]';

rng(1);ref_sequence = randi(10, 1, 100) * 0.5;
ref_sampling_time = 1.45672;

%sim('reference_generator');
%ref = ref.data;
%ref_input.time = t;
%ref_input.signals.values = [ref];
%ref_input.signals.dimensions = 1;

% noises
noise = plant.noise_level .* randn(numel(t), 1);
noise_input.time = t;
noise_input.signals.values = [noise];
noise_input.signals.dimensions = 1;

% disturbances
sim('disturbance_generator');
d.data = plant.disturbance_on .* d.data;
d_input.time = t;
d_input.signals.values = [d.data];
d_input.signals.dimensions = 1;


%% Run Simulink model
mdl = 'lqr_period_afbs_simu';
open_system(mdl);
afbs_parameters = [g_TaskPeriod];       % passing parameters to AFBS-kernel

% record in diary
if (exist('log.txt', 'file') == 2)
    delete('log.txt');
end

diary('log.txt');
diary on;

% start simulation
sim(mdl);

diary off;

%filename = sprintf('Ts_%d.mat', g_TaskPeriod);
%save(filename, 'plant', 't', 'ref', 'y', 'u');


%% Output results
%state_cost = compute_quadratic_control_cost(ref - y, 0, simu.sampling_time, 1, 0, 0);
%control_cost = compute_quadratic_control_cost(0, u, simu.sampling_time, 0, 0, 1);
%fprintf('State cost: %f \r\n', state_cost);
%fprintf('Control cost: %f \r\n', control_cost);
