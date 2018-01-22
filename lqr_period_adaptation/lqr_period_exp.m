% -------------------------------------------------------------------------
% mpc_exp.m
% Explore MPC performance v.s. period.
% Author: Xiaotian Dai
% https://uk.mathworks.com/help/mpc/examples/control-of-a-single-input-single-output-plant.html
% -------------------------------------------------------------------------

clear; %close all;

addpath('../../Toolbox/')


%% Parameters
% system dynamic model define
% period should be 5% - 10% of the rising time (settling time for 1st order systems)
% settling time = 4 * tau
tau = 1.0;
plant = tf([3], [tau 1]);
mpc_param.plant = plant;

simu.simulation_time = 100;
simu.samlping_time = 0.010;
simu.noise_level = 0 * 1e-5;

% task period define
% 2.5% - 100% of Tr
task_param.hi_array = 0.2:0.5:0.4;
task_param.ci = 0.1;

h_array = [];
state_cost_array = [];
control_cost_array = [];

% MPC
mpc_param.p = 10;
mpc_param.m = 3;


%% loop periods
for h_this = task_param.hi_array

% define a MPC controller object
mpc_param.Ts = h_this;
mpcobj = mpc(mpc_param.plant, mpc_param.Ts, mpc_param.p, mpc_param.m);

% constraints
mpcobj.MV = struct('Min', -10, 'Max', 10);

mdl = 'mpc_period_exp_simulink';
open_system(mdl);
sim(mdl);


% output error
state_cost = compute_quadratic_control_cost(ref.data(:) - y.data, 0, simu.samlping_time, 1, 0, 0);
state_cost_avg = state_cost / simu.simulation_time;

control_cost = compute_quadratic_control_cost(0, u.data, simu.samlping_time, 0, 0, 1);
control_cost_avg = control_cost / simu.simulation_time;

fprintf('State cost: %f \r\n', state_cost);

h_array = [h_array h_this];
state_cost_array = [state_cost_array state_cost];
control_cost_array = [control_cost_array control_cost];

filename = sprintf('Ts_%0.2f_data.mat', h_this);
save(filename, 'h_this', 'y', 'u');

end


%% plot result
subplot(2, 1, 1)
plot(h_array, state_cost_array, '-x');
hold on
xlabel('control interval')
ylabel('state cost (CV)')

subplot(2, 1, 2)
plot(h_array, control_cost_array, '-x');
hold on
xlabel('control interval')
ylabel('control effort (MV)')

filename = sprintf('tau_%0.1f_data.mat', tau);
save(filename, 'plant', 'mpcobj', 'h_array', 'state_cost_array', 'control_cost_array');

rmpath('../../Toolbox/')