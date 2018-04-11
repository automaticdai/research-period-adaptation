% -------------------------------------
% monte_carlo_wrap.m
% Xiaotian Dai
% University of York
% -------------------------------------

% for reproducibility
rng default

%% Configurations
% define task model
%tau = 5; plant.sys = tf([10],[tau 1]);
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
R = 0.1;
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
ctrl.ref = 1;

% define task model
task.T_U = 0.6 / plant.bwcl;
task.T_L = 0.2 / plant.bwcl;
task.T = 0.000;                 % 10ms - 30ms

% RTA to get BCRT and WCRT
run('rta_test.m')

task.runtime.bcrt = 0.001;
task.runtime.wcrt = 0.006;
task.runtime.ri = ri;

assert(task.runtime.wcrt <= task.T_L)

% define simulation parameter
conf.simu_times = 3000;
conf.simu_time_min = 1.0;
conf.simu_samplingtime = 0.0001;

conf.noise_on = 0;
conf.noise_level = -20;

conf.sampling_method = 3; % 1: uniform, 2: norm, 3: empirical

% performance indices
pi.T = [];
pi.Tss = [];
pi.J = [];
pi.IAE = [];
pi.ISE = [];

%% Run Simulation
for period = 0.020:0.001:0.020 %task.T_L:0.001:task.T_U
    task.T = period;
    run('monte_carlo_lsim.m')
end

save('pi_.mat','pi','task','plant','ctrl','conf')