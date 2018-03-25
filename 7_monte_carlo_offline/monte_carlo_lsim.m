% define task model
sys = zpk([],[-10+10j -10-10j],100);
plant.model_ss = ss(sys);
plant.order = order(sys);

% define 
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
ctrl.ref = 1;

% define task model
task.bcrt = 0.001;
task.wcrt = 0.005;
task.list = 0;
task.period = 0.010; % 10ms - 30ms

% Define simulation parameter
conf.simu_count = 1;
conf.simu_time_max = 1.0;
conf.simu_samplingtime = 0.001;

% Simulation variables containers
simu.count = 0;
simu.y = [0];
simu.x = zeros(1, plant.order);
simu.u = [0];
simu.t = [0];

% initial conditions
g_time = 0;

if plant.order == 1
    x0 = [0];
elseif plant.order == 2
    x0 = [0;0];
else
    %pass
end

% run simulation
% s0: task start
g_time = 0;
simu.state = 0;

% s0 -> s1: first job release delay
simu.r = 0;

while g_time <= conf.simu_time_max
    % s1: task released
    g_time = g_time + simu.r;
    
    % s1 -> s2
    % sampling delay
    
    % s2: sampling
    ctrl.x = simu.x(end,:)';
       
    % s2 -> s3
    % input-output latency
    
    % s3: control output & task finished
    ctrl.u = -1 * ctrl.K * ctrl.x + (ctrl.ref * ctrl.N_bar);
    
    % s3 -> s1
    simu.tf = task.period;
    
    % save result to simulation container
    simu.x = [simu.x;x];
    simu.y = [simu.y;y];
    simu.u = [simu.u;u];
    simu.t = [simu.t;t + g_time];
    
    % update simulation timer
    g_time = g_time + simu.tf;
end % end of while    


while 0 % g_time <= conf.simu_time_max        
    % computer io latency (task completation time)
    simu.tf = task.period;
    
    ctrl.x = simu.x(end,:)';
    ctrl.u = -1 * ctrl.K * ctrl.x + (ctrl.ref * ctrl.N_bar);
    
    t = 0:conf.simu_samplingtime:simu.tf;
    u = ones(numel(t), 1) * ctrl.u;

    % simulate the system with lsim
    [y, t, x] = lsim(plant.model_ss, u, t, x0);
    
    % update initial condition
    if plant.order == 1
        x0 = x(end);
    elseif plant.order == 2
        x0 = x(end,:);
    else
        % pass
    end

    % save result to simulation container
    simu.x = [simu.x;x];
    simu.y = [simu.y;y];
    simu.u = [simu.u;u];
    simu.t = [simu.t;t + g_time];
    
    % update simulation timer
    g_time = g_time + simu.tf;
    
end % end of while

compute_steady_state_time(simu.y, simu.t, ctrl.ref, 0.05)

%plot result (optional)
subplot(3,1,1)
stairs(simu.t, simu.y)
title('Response')

subplot(3,1,2)
stairs(simu.t, simu.x)
title('States')

subplot(3,1,3)
stairs(simu.t, simu.u)
title('Control Inputs')