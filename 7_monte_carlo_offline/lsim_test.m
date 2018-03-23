% Define task model
sys = zpk([],[-10+10j -10-10j],1);
plant.model_ss = ss(sys);
plant.order = order(sys);

% Define LQR controller model
A = plant.model_ss.a;
B = plant.model_ss.b;
C = plant.model_ss.c;
D = plant.model_ss.d;

Q = 100 * eye(plant.order);
R = 10;
N = 0;

[K,S,E] = lqr(A, B, Q, R, N);
N_bar = rscale(A, B, C, D, K);

ctrl.K = K;
ctrl.N_bar = N_bar;
ctrl.x = zeros(plant.order, 1);
ctrl.u = 0;
ctrl.y = 0;
ctrl.ref = 1;

% Define simulation parameter
conf.simu_count = 1;
conf.simu_time_max = 1.0;
conf.simu_samplingtime = 0.01;


% Simulation variables containers
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
% waiting job release
% execute sampling
% waiting job finish
% update control
while g_time <= conf.simu_time_max
    
    % computer io latency (task completation time)
    simu.tf = 0.1;
    
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