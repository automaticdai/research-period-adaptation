% -------------------------------------------------------------------------
% result_group_a
% -------------------------------------------------------------------------
% from: mpc_period_exp.m
% reference: period 20s, pulse 50%, phase delay 1s

% plant = tf([3], [1 1]);

% simu.simulation_time = 200;
% simu.samlping_time = 0.010;
% simu.noise_level = 0.001;

% task_param.hi_array = 0.1:0.01:4;
% task_param.ci = 0.1;

% mpc_param.p = 10;
% mpc_param.m = 3;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% result_group_b
% -------------------------------------------------------------------------
% from: mpc_period_exp.m
% reference: period 50s, pulse 50%, phase delay 0s
%
% tau = 1;
% plant = tf([3], [tau 1]);
% mpc_param.plant = plant;
%
% simu.simulation_time = 5;
% simu.samlping_time = 0.010;
% simu.noise_level = 0 * 1e-5;
%
% % task period define
% % 2.5% - 100%
% task_param.hi_array = 0.2:0.05:0.4; % 4
% task_param.ci = 0.1;
%
% % MPC
% mpc_param.p = 10;
% mpc_param.m = 3;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% result_group_c
% -------------------------------------------------------------------------
% from: mpc_period_with_abitary_reference.m
%       mpc_steady_state_analysis.m
%
% simu.time = 10000.0;
% simu.samlping_time = 0.01;
% opt.noise_on = 1;
% opt.disturbance_on = 0;

% tau = 2.0;
% plant = tf([10],[tau 1]);
%
% mpc_param.plant_ref = plant;
% mpc_param.Ts = 0.05:0.05:0.8;
%
% t = [0:simu.samlping_time:simu.time]';
%
% rng(1);ref_sequence = randi(5, 1, 50) - 1;
% ref_sampling_time = 3.78;
% sim('reference_generator');
%
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% result_group_d
% -------------------------------------------------------------------------
% same with result_group_d, with noise off.