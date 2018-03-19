global g_Ts

addpath('./toolbox')

simu.time = 1.0;
simu.samlping_time = 0.001;
t = [0:simu.samlping_time:simu.time]';

tau = 0.1;
plant = tf([10],[tau 1]);
[A,B,C,D] = tf2ss(plant.num{1}, plant.den{1});

ctrl_K = 4.1421;
ctrl_N = 0.1414;
ctrl_C = C;

% set period (ms)
for i = 100:5:100
    g_Ts = i / 1000;
    
    % run the simulation
    sim('lqr_period_ideal');
    
    % get quadratic cost
    tss = compute_steady_state_time(y, t, ref, 0.05);
    idx = tss / simu.samlping_time;
    
    % compute quadaratic cost
    j = compute_quadratic_control_cost(1 - y, ...
        u, simu.samlping_time, 1, 0, 0)
    scatter(i, tss, 'bx');
    hold on
end
