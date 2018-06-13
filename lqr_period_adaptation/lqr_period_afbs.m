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

%g_TaskPeriod = 0.010;

%% Compile the Kernel
cd('afbs-kernel')
mex -g ./core/kernel.cpp ./core/afbs.cpp ./core/app.cpp ./core/utils.cpp ./core/task.cpp
mex -g ./sfun_reference_cpp.cpp
cd('..')


%% Simulation parameters
simu.time = 1000;
simu.sampling_time = 100 * 10^-6;    % 100 us


%% System dynamic model
% first-order system
% period should be 5% - 10% of the rising time (settling time for 1st order systems)
% settling time = 4 * tau
%tau = 0.1;
%plant = tf([10],[tau 1]);

% second-order system
plant.sys = zpk([],[10+25j 10-25j],100);
plant.model_ss = ss(plant.sys);
plant.order = order(plant.sys);
plant.bwcl = bandwidth(feedback(plant.sys, 1));

h_min = 0.2 / plant.bwcl;
h_max = 0.6 / plant.bwcl;

A = plant.model_ss.a;
B = plant.model_ss.b;
C = plant.model_ss.c;
D = plant.model_ss.d;

% plant noise model
plant.noise_level = 1e-4;
plant.noise_sampling_time = 1e-5;
%plant.disturbance_on = 0;

% LQR controller
Q = 10 * eye(plant.order);
R = 0.1;
N = zeros(plant.order, 1);

%[K,S,E] = lqrd(A, B, Q, R, N, 0.010);
[K,S,E] = lqr(A, B, Q, R, N);
%N_bar = (-1 * C * (A - B * K - 1)^(-1) * B) ^ (-1);
N_bar = rscale(A, B, C, D, K);
ctrl.K = K;
ctrl.N_bar = N_bar;


%% External signals
% t = [0:simu.sampling_time:simu.time]';

% references (legency)
%rng(1);ref_sequence = randi(10, 1, 100) * 0.5;
%ref_sampling_time = 1.45672;

%sim('reference_generator');
%ref = ref.data;
%ref_input.time = t;
%ref_input.signals.values = [ref];
%ref_input.signals.dimensions = 1;

% noises (legency)
% noise = plant.noise_level .* randn(numel(t), 1);
% noise_input.time = t;
% noise_input.signals.values = [noise];
% noise_input.signals.dimensions = 1;

% disturbances (legency)
% sim('disturbance_generator');
% d.data = plant.disturbance_on .* d.data;
% d_input.time = t;
% d_input.signals.values = [d.data];
% d_input.signals.dimensions = 1;


%% Run Simulink model
mdl = 'lqr_period_afbs_simu';
open_system(mdl);
afbs_parameters = [g_TaskPeriod];       % passing parameters to AFBS-kernel

% record in diary
log_file_name = sprintf('./logs/log%.0f.log', g_TaskPeriod * 1e5);
if (exist(log_file_name, 'file') == 2)
    diary off;
    delete(log_file_name);
end

diary(log_file_name);
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
