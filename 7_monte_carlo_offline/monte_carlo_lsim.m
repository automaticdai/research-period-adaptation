% -------------------------------------
% monte_carlo_lsim.m
% Xiaotian Dai
% University of York
% -------------------------------------

%% Simulation outer loop
% Simulation variables
simu.count = 0;     % simulation count

while simu.count < conf.simu_times

simu.count = simu.count + 1;

fprintf('Ti = %f, i = %d \r', task.T, simu.count);

simu.tr = 0;        % release time
simu.ts = 0;        % sampling delay
simu.tf = 0;        % finish time (from sampling to finish)

% initial conditions
g_time = 0;
simu.state = 0;     % simulation state

x0 = 2.530 * ones(plant.order, 1);

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
        % sampling response time
        % (uniform distribution)
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
if false
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
end

% analysis
simu.tss = compute_steady_state_time(simu.y, simu.t, ctrl.ref, 0.05);
simu.cost = compute_quadratic_control_cost(simu.x, simu.u, conf.simu_samplingtime, Q, N, R);

pi.x = [pi.x task.T];
pi.y1 = [pi.y1 simu.cost];
pi.y2 = [pi.y2 simu.tss];

end