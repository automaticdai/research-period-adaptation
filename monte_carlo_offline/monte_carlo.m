% monte_carlo.m
% Xiaotian Dai, University of York
% Generating system performance index using Monte Carlo simulation
% Task execution uncertainty is abstracted into a uniformly response-time distribution

clear; clc;

if (exist('log.txt', 'file') == 2)
    delete('log.txt');
end

diary('log.txt');
diary on;

%% variables for saving results
mc_j_cost_aa = [];
mc_j_cost_temp = [];

mc_tss_aa = [];
mc_tss_temp = [];


%% configurations
% define simulation parameters
conf.simu_count = 100;
conf.simu_time_max = 1.0;

conf.period_min = 0.030;
conf.period_max = 0.030;
conf.period_step = 0.003;

% define system dynamic model in state space
%   for first order system:
%   period should be 5% - 10% of the rising time (settling time for 1st order systems)
%   settling time = 4 * tau
tau = 0.1;
plant.model = tf([10],[tau 1]);
[A, B, C, D] = tf2ss(plant.model.num{1}, plant.model.den{1});
plant.model_ss = ss(A,B,C,D);

% define LQR controller model
Q = 1;
R = 0.01;
N = 0;
[K,S,E] = lqr(A, B, Q, R, N);
%N_bar = (-1 * C * (A - B * K - 1)^(-1) * B) ^ (-1);
N_bar = rscale(A, B, C, D, K);

ctrl.K = K;
ctrl.N_bar = N_bar;
ctrl.u = 0;
ctrl.y = 0;

% define task model
task.bcet = 0.001;
task.wcet = 0.005;
task.list = 0;

% RTA to get BCRT and WCRT
task.runtime.bcrt = 0.000;
task.runtime.wcrt = 0.000;


%% start simulation
task.runtime.period = conf.period_min;
while (task.runtime.period <= conf.period_max)
simu.count = 0;

%% a simulation group with the same period
while (simu.count < conf.simu_count)

simu.count = simu.count + 1;

% simulation parameters
simu.ref = 1;
simu.state = 0;
simu.t = [0];
simu.u = [0];
simu.u_t = [0];
simu.x = [0];
simu.y = [0];

% simulation inner loop
% s0: start
g_time = 0;
simu.state = 0;

% s0 -> s1
% task start delay due to task phasing/synchronization
simu.r = task.runtime.period * rand(1);

while (g_time < conf.simu_time_max)
% s1: released
g_time = g_time + simu.r;
%fprintf('%0.4f, release \r', g_time)
simu.state = 1;

% s1 -> s2
% assuming no sampling delay
% ode45 (skipped)

% s2: sampling
g_time = g_time + 0;
%fprintf('%0.4f, sampling \r', g_time)
ctrl.x = simu.x(end);
ctrl.y = simu.y(end);
simu.state = 2;

% s2 -> s3
% control delay
% roll and sample a finish time
simu.tf = task.runtime.bcrt + (task.runtime.wcrt - task.runtime.bcrt) .* rand(1);

if (simu.tf ~= 0)
    % ode45
    tspan = [0 simu.tf];
    init_cond = [simu.x(end)];
    [t, y] = ode45(@(t,x) sys(t, x, ctrl.u, plant.model_ss), tspan, init_cond);
    simu.t = [simu.t;t + g_time];
    simu.x = [simu.x;y];
    simu.y = [simu.y;plant.model_ss.C .* y];
end

% s3: change output
% control output: u = -1 * K * x + N * ref;
g_time = g_time + simu.tf;
%fprintf('%0.4f, output \r', g_time)
ctrl.u = -1 * ctrl.K * ctrl.x + (simu.ref * ctrl.N_bar);

simu.u = [simu.u; ctrl.u];
simu.u_t = [simu.u_t; g_time];
simu.state = 3;

% s3 -> s1: wait for the next release
simu.r = task.runtime.period - simu.tf;
% ode45
tspan = [0 simu.r];
init_cond = [simu.x(end)];
[t, y] = ode45(@(t,x) sys(t, x, ctrl.u, plant.model_ss), tspan, init_cond);
simu.t = [simu.t;t + g_time];
simu.x = [simu.x;y];
simu.y = [simu.y;plant.model_ss.C .* y];

% test the terminating condition: is the system in steady-state?

end % end of while

simu.state = 4;

% analysis cost
t_b = [0;diff(simu.t)];
mc_j_cost = sum((simu.y - 1) .^ 2 .* t_b);

% analysis steady-state time
mc_tss = compute_steady_state_time(simu.y, simu.t, 1, 0.05);
fprintf('%f, %f, %f\r', task.runtime.period, mc_tss, mc_j_cost);

% analysis and save result
mc_j_cost_temp = [mc_j_cost_temp;mc_j_cost];
mc_tss_temp = [mc_tss_temp; mc_tss];
% save()
end

% increase period
task.runtime.period = task.runtime.period + conf.period_step;
mc_j_cost_aa = [mc_j_cost_aa, mc_j_cost_temp];
mc_j_cost_temp = [];

mc_tss_aa = [mc_tss_aa, mc_tss_temp];
mc_tss_temp = [];
end

diary off;