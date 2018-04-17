% -------------------------------------------------------------------------
% mpc_period_with_abitary_reference.m
% Explore MPC performance with period.
% Author: Xiaotian Dai
% https://uk.mathworks.com/help/mpc/examples/control-of-a-single-input-single-output-plant.html
% -------------------------------------------------------------------------
 
close all;
addpath('../../Toolbox/')

global g_Ts;

%% Simulation parameters
simu.time = 1000.0;
simu.samlping_time = 0.010;

opt.noise_level = 0.03;
opt.disturbance_on = 1;

%% System dynamic model define
% period should be 5% - 10% of the rising time (settling time for 1st order systems)
% settling time = 4 * tau
tau = 2.0;
plant = tf([10],[tau 1]);

mpc_param.plant_ref = plant;
mpc_param.Ts = g_Ts;

% inputs
t = [0:simu.samlping_time:simu.time]';

rng(1);ref_sequence = randi(5, 1, 50) - 1;
ref_sampling_time = 3.78;
sim('reference_generator');
%ref = (square((t * 2 * pi) / 5) + 1) ./ 2; % period = ? s

ref = ref.data;
ref_input.time = t;
ref_input.signals.values = [ref];
ref_input.signals.dimensions = 1;

noise = opt.noise_level .* randn(numel(t), 1);
noise_input.time = t;
noise_input.signals.values = [noise];
noise_input.signals.dimensions = 1;

sim('disturbance_generator');
d.data = opt.disturbance_on .* d.data;
d_input.time = t;
d_input.signals.values = [d.data];
d_input.signals.dimensions = 1;


%% MPC controller
mpc_param.p = 10;
mpc_param.m = 3;
mpcobj = mpc(mpc_param.plant_ref, mpc_param.Ts, mpc_param.p, mpc_param.m);


%% constraints
mpcobj.MV = struct('Min', -10, 'Max', 10);

mdl = 'mpc_period_with_r_and_d_simulink';
%mdl = 'pid_simulink_with_r_and_d';
open_system(mdl);
sim(mdl);

filename = sprintf('Ts_%0.2f.mat', mpc_param.Ts);
save(filename, 'plant', 'mpcobj', 't', 'ref', 'y', 'u');

%% output error
state_cost = compute_quadratic_control_cost(ref - y, 0, simu.samlping_time, 1, 0, 0);
control_cost = compute_quadratic_control_cost(0, u, simu.samlping_time, 0, 0, 1);
fprintf('State cost: %f \r\n', state_cost);
fprintf('Control cost: %f \r\n', control_cost);

rmpath('../../Toolbox/')