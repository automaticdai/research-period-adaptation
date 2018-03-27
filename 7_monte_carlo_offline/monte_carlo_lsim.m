% -------------------------------------
% monte_carlo_lsim.m
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
task.T = 0.050; % 10ms - 30ms
task.C = 0.001;
task.taskset_list = 0;

task.runtime.bcrt = 0.001;
task.runtime.wcrt = 0.010;

% define simulation parameter
conf.simu_times = 1;
conf.simu_time_min = 1.0;
conf.simu_samplingtime = 0.0001;

conf.noise_level = -20;
conf.noise_on = 1;


%% Simulation outer loop
% Simulation variables
simu.count = 0;     % simulation count

while simu.count < conf.simu_times

simu.count = simu.count + 1;    

simu.tr = 0;        % release time
simu.ts = 0;        % sampling delay
simu.tf = 0;        % finish time (from sampling to finish)

% initial conditions
g_time = 0;
simu.state = 0;     % simulation state

x0 = 0.2530 * ones(plant.order, 1);

simu.x = x0';
simu.y = C * x0;
simu.u = [0];
simu.t = [0];
simu.ut = [0];


% Simulation inner loop
i = 0;

% control maximum simulation length
while i < 1000
    
switch simu.state
    case 0
        % s0: task start
        g_time = 0;
        
        % s0 -> s1: first job release delay
        simu.tr = 0;
        g_time = g_time + simu.tr;
        simu.state = 1;
        
    case 1
        % s1: task released
        % 
        
        % s1 -> s2: sampling delay
        % sampling delay is ignored
        simu.ts = 0;
        g_time = g_time + simu.ts;
        simu.state = 2;
    
    case 2
        % s2: task activated, sampling input
        ctrl.x = simu.x(end, 1:plant.order)';
        
        % s2 -> s3: task executing
        simu.tf = task.runtime.bcrt + (task.runtime.wcrt - task.runtime.bcrt) .* rand(1);
        
        t = 0:conf.simu_samplingtime:simu.tf;
        noises = wgn(numel(t), 1, conf.noise_level) * conf.noise_on;
        u = ones(numel(t), 1) * ctrl.u  + noises;
        x0 = simu.x(end, 1:plant.order)';
        
        if numel(t) > 1
            [y, t, x] = lsim(plant.model_ss, u, t, x0);

            % save result to simulation container
            simu.x = [simu.x;x];
            simu.y = [simu.y;y];
            simu.u = [simu.u;u];
            simu.t = [simu.t;t + g_time];
        end
        
        simu.state = 3;
        g_time = g_time + simu.tf;
        
    case 3
        simu.tr = task.T - simu.tf;
        
        % s3: output & task finished
        ctrl.u = -1 * ctrl.K * ctrl.x + (ctrl.ref * ctrl.N_bar);
 
        % s3 -> s1
        t = 0:conf.simu_samplingtime:simu.tr;
        noises = wgn(numel(t), 1, conf.noise_level) * conf.noise_on;
        u = ones(numel(t), 1) * ctrl.u + noises;
        x0 = simu.x(end, 1:plant.order)';

        if numel(t) > 1
            [y, t, x] = lsim(plant.model_ss, u, t, x0);

            % save result to simulation container
            simu.x = [simu.x;x];
            simu.y = [simu.y;y];
            simu.u = [simu.u;u];
            simu.t = [simu.t;t + g_time];
        end
        
        % be ready for the next release
        g_time = g_time + simu.tr;
        simu.state = 1;
        
        if (g_time > conf.simu_time_min)
            break
        end
    
    otherwise
        disp('Error: unknown state!');

end

%fprintf('%f, state %d \r', g_time, simu.state)
i = i + 1;

end


% plot result (optional)
subplot(3,1,1)
stairs(simu.t, simu.y)
title('Response')
hold on;

subplot(3,1,2)
stairs(simu.t, simu.x)
title('States')
hold on;

subplot(3,1,3)
stairs(simu.t, simu.u)
title('Control Inputs')
hold on;

% analysis
pi.tss = compute_steady_state_time(simu.y, simu.t, ctrl.ref, 0.05);
pi.cost = compute_quadratic_control_cost(simu.x, simu.u, conf.simu_samplingtime, Q, N, R);
fprintf('%f \r', pi.cost)


end