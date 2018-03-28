% -------------------------------------
% monte_carlo_wrap.m
% Xiaotian Dai
% University of York
% -------------------------------------

%% Configurations
% define task model
plant.sys = zpk([],[-10+10j -10-10j],100);
plant.model_ss = ss(plant.sys);
plant.order = order(plant.sys);
plant.bwcl = bandwidth(feedback(plant.sys, 1));

% design LQR controller
A = plant.model_ss.a;
B = plant.model_ss.b;
C = plant.model_ss.c;
D = plant.model_ss.d;

Q = 1 * eye(plant.order);
R = 0.01;
N = zeros(plant.order, 1);

%[K,S,E] = lqrd(A, B, Q, R, N, 0.010);
[K,S,E] = lqr(A, B, Q, R, N);
N_bar = rscale(A, B, C, D, K);

% define contol model
ctrl.K = K;
ctrl.N_bar = N_bar;
ctrl.x = zeros(plant.order, 1);
ctrl.u = 0;
ctrl.y = 0;
ctrl.ref = 0;

% define task model
task.T_U = 0.6 / plant.bwcl;
task.T_L = 0.2 / plant.bwcl;
task.T = 0.013; % 10ms - 30ms
task.C = 0.001;
task.taskset_list = 0;

task.runtime.bcrt = 0.000;
task.runtime.wcrt = 0.002;

% define simulation parameter
conf.simu_times = 100;
conf.simu_time_min = 1.0;
conf.simu_samplingtime = 0.0001;

conf.noise_level = -20;
conf.noise_on = 1;

pi.x = [];
pi.y1 = [];
pi.y2 = [];

%% Run Simulation
for period = task.T_L:0.001:task.T_U
    task.T = period;
    run('monte_carlo_lsim.m')
end

save('pi_.mat','pi','task','plant','ctrl','conf')