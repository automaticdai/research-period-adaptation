% -------------------------------------
% monte_carlo_wrap.m
% Xiaotian Dai
% University of York
% -------------------------------------

% for reproducibility
rng default
%rng(100)

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


%% Task model
kernel_time = 10 * 10^-6;      % 10us

task.T_U = 0.6 / plant.bwcl;
task.T_L = 0.2 / plant.bwcl;
task.T = 1000;                 % task designed period (in kernel time)
task.C = 100;                  % task WCET (in kernel time)

% define task set
taskset = [taskset; size(taskset,1), task.C, task.T, task.T];

% RTA to get BCRT and WCRT  
[bcrt, wcrt] = rta(taskset);

bcrt_a = bcrt .* kernel_time;
wcrt_a = wcrt .* kernel_time;

task.runtime.bcrt = bcrt_a(end);
task.runtime.wcrt = wcrt_a(end);

assert(task.runtime.wcrt <= task.T_L)
assert(task.runtime.wcrt >= task.runtime.bcrt)


%% Simulation parameters
conf.simu_times = 3000;
conf.simu_time_max = 0.5;
conf.simu_samplingtime = 1 * 10^-4;

conf.period_min = 0.010;
conf.period_max = 0.025;
conf.period_step = 0.001;

conf.sync_mode = 1;       % sync of the first release job, 0: full, 1: not sync, 2: worst-case
conf.sampling_method = 1; % response time: 1: uniform, 2: norm, 3: empirical

if (conf.sampling_method == 3)
    % load Ri distribution profile
    load('ri_afbs_10ms')
    task.runtime.ri = ri;
end

conf.noise_on = 0;
conf.noise_level = -20;


%% Run Simulation
for period = 0.010:0.001:0.025 %task.T_L:0.001:task.T_U
    task.T = period;
    
    % performance indices
    pi.T = [];
    pi.Tss = [];
    pi.J = [];
    pi.IAE = [];
    pi.ISE = [];
    
    % run monte carlo simulation
    run('monte_carlo_lsim.m')
    
    save(['./_temp/' 'pi_mc_uniform_' num2str(period * 1000) 'ms.mat'], ...
          'pi','task','plant','ctrl','conf')
end
