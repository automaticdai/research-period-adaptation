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
plant.sys = zpk([],[10+25j 10-25j],100);
plant.model_ss = ss(plant.sys);
plant.order = order(plant.sys);
plant.bwcl = bandwidth(feedback(plant.sys, 1));

% design LQR controller
A = plant.model_ss.a;
B = plant.model_ss.b;
C = plant.model_ss.c;
D = plant.model_ss.d;

Q = 10 * eye(plant.order);
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


%% Simulation parameters
% path to afbs source data
addpath('E:\Workstation\Git\period-adaptation\data\dataset_c\afbs')

% simulation times
conf.simu_times = 1000;
conf.simu_time_max = 3.0;
conf.simu_samplingtime = 1 * 10^-4;

conf.noise_on = 1;
conf.noise_level = -40;

conf.period_min  = 0.010;
conf.period_max  = 0.014;
conf.period_step = 0.001;

conf.sync_mode = 1;       % sync of the first release job, 0: full, 1: not sync, 2: worst-case
conf.sampling_method = 1; % response time: 1: uniform, 2: norm, 3: empirical

% load Ri distribution profile, if samlping method is empirical
if (conf.sampling_method == 3)
    load('ri_afbs_10ms')
    task.runtime.ri = ri;
end


%% Run Simulation
for period = conf.period_min:conf.period_step:conf.period_max % task.T_L:0.001:task.T_U

    disp(period)
    task.T = period;
    
    % load BCRT and WCRT
    filename = ['pi_afbs_' num2str(period * 1e5)];
    load(filename)
    
    task.runtime.bcrt = pi.bcrt(end) / 1e5;
    task.runtime.wcrt = pi.wcrt(end) / 1e5;

    %disp(task.runtime.bcrt)
    %disp(task.runtime.wcrt)
    
    clear pi;
    
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
