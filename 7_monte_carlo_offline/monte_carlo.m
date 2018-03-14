% monte_carlo.m
% Xiaotian Dai, University of York
% Generating system performance index using Monte Carlo simulation
% Task execution uncertainty is abstracted into a uniformly response-time distribution

clear; clc;

%% configurations
% define simulation parameters
conf.time = 1000;
conf.period_min = 0.050;
conf.period_max = 0.100;
conf.period_step = 0.005;

% define system dynamic model in state space
tau = 0.1;
plant.model = tf([10],[tau 1]);
[A, B, C, D] = tf2ss(plant.model.num{1}, plant.model.den{1});
plant.model_ss = ss(A,B,C,D);

% define LQR controller model
ctrl.K = 0.0499;
ctrl.N_bar = 0.1005;
ctrl.u = 0;
ctrl.y = 0;

% define task model
task.bcet = 0.001;
task.wcet = 0.005;
task.list = 0;

% RTA to get BCRT and WCRT
task.model.bcrt = 0.001;
task.model.wcrt = 0.005;


%% start simulation
while true
% simulation outer loop
task.model.period = 0.100;

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
simu.r = task.model.period * rand(1);

while (g_time < 2)
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
simu.tf = task.model.bcrt + (task.model.wcrt - task.model.bcrt) .* rand(1);
% ode45
tspan = [0 simu.tf];
init_cond = [simu.x(end)];
[t, y] = ode45(@(t,x) sys(t, x, ctrl.u, plant.model_ss), tspan, init_cond);
simu.t = [simu.t;t + g_time];
simu.x = [simu.x;y];
simu.y = [simu.y;plant.model_ss.C .* y];

% s3: change output
% control output: u = -1 * K * x + N * ref;
g_time = g_time + simu.tf;
%fprintf('%0.4f, output \r', g_time)
ctrl.u = -1 * ctrl.K * simu.x(end) + (simu.ref * ctrl.N_bar);

simu.u = [simu.u; ctrl.u];
simu.u_t = [simu.u_t; g_time];
simu.state = 3;

% s3 -> s1: wait for the next release
simu.r = task.model.period - simu.tf;
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
fprintf('%f \r', sum((simu.y - 1) .^ 2 .* t_b));

% analysis and save result
% save()
end