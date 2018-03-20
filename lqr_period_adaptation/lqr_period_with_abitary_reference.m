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

global g_Ts;

%% Compile the Kernel
cd('afbs-kernel')
mex -g ./core/kernel.cpp ./core/afbs.cpp ./core/app.cpp ./core/utils.cpp ...
       ./core/task.cpp
cd('..')

%% Simulation parameters
% controller periods
g_Ts = 100;

% task periods
parameters = [g_Ts];

simu.time = 1000.0;
simu.samlping_time = 0.001;

opt.noise_level = 0.01;
opt.disturbance_on = 0;

%% System dynamic model
% period should be 5% - 10% of the rising time (settling time for 1st order systems)
% settling time = 4 * tau
tau = 0.1;
plant = tf([10],[tau 1]);
[A,B,C,D] = tf2ss(plant.num{1}, plant.den{1});

% references
t = [0:simu.samlping_time:simu.time]';

rng(1);ref_sequence = randi(6, 1, 50);
ref_sampling_time = 1.9;
sim('reference_generator');

ref = ref.data;
ref_input.time = t;
ref_input.signals.values = [ref];
ref_input.signals.dimensions = 1;

% noises
noise = opt.noise_level .* randn(numel(t), 1);
noise_input.time = t;
noise_input.signals.values = [noise];
noise_input.signals.dimensions = 1;

% disturbances
sim('disturbance_generator');
d.data = opt.disturbance_on .* d.data;
d_input.time = t;
d_input.signals.values = [d.data];
d_input.signals.dimensions = 1;

%% Controller Parameters
Q = 1;
R = 1;
N = 0;
[K,S,E] = lqr(A, B, Q, R, N);
%N_bar = (-1 * C * (A - B * K - 1)^(-1) * B) ^ (-1);
N_bar = rscale(A, B, C, D, K);

%% Run Simulink model
mdl = 'lqr_period_with_r_and_d_simulink';
open_system(mdl);

% record in diary
if (exist('log.txt', 'file') == 2)
    delete('log.txt');
end

diary('log.txt');
diary on;

% start simulation
sim(mdl);

diary off;

%filename = sprintf('Ts_%d.mat', g_Ts);
%save(filename, 'plant', 't', 'ref', 'y', 'u');

%% output error
%state_cost = compute_quadratic_control_cost(ref - y, 0, simu.samlping_time, 1, 0, 0);
%control_cost = compute_quadratic_control_cost(0, u, simu.samlping_time, 0, 0, 1);
%fprintf('State cost: %f \r\n', state_cost);
%fprintf('Control cost: %f \r\n', control_cost);
