global g_Ts

addpath('./toolbox')

simu.time = 1.0;
simu.samlping_time = 0.001;
ref_mag = 1.0;

t = [0:simu.samlping_time:simu.time]';

% define task model
tau = 5; plant.sys = tf([10],[tau 1]);
%plant.sys = zpk([],[-10+10j -10-10j],100);

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

%[K,S,E] = lqrd(A, B, Q, R, N, 0.030);
[K,S,E] = lqr(A, B, Q, R, N);
N_bar = rscale(A, B, C, D, K);

ctrl_K = K;
ctrl_N = N_bar;

j_a = [];
ti_a = [];
% set period (ms)
for i = 0.2 / plant.bwcl:0.01:0.2 / plant.bwcl
    g_Ts = i
    
    % run the simulation
    sim('lqr_period_ideal');
    
    % get quadratic cost
    tss = compute_steady_state_time(y, t, ref, 0.05);
    idx = tss / simu.samlping_time;
    
    % compute quadaratic cost
    x_desired = ref * (-1 * inv(A - B * K) * B * N_bar)';
    j = compute_quadratic_control_cost((x - x_desired) ./ ref_mag, ...
        u ./ ref_mag, simu.samlping_time, Q, N, R);
    j_a = [j_a j];
    ti_a = [ti_a g_Ts];
end

scatter(ti_a, j_a, 'bx');