% -------------------------------------------------------------------------
% jitter_hybrid.m
% Simulate a digital LQR control system with release jitter
% Xiaotian Dai, University of York, 2017
% -------------------------------------------------------------------------

%global g_period

% simulation parameters
x_order = 2;                    % system order
u_dim = 1;                      % input dimension
y_dim = 1;                      % output dimension
simu.step = 0.00010;            % simulation time step size
simu.time = 0.5;                % simulation time length
T = 0.1;                        % control period
j_r = 0;                        % release jitter
j_l = 0;                        % input-output latency

% simulation variables
x = zeros(x_order,1);           % system state
x_dot = zeros(x_order,1);       % system state (derivative)
y = zeros(y_dim,1);             % system output
u = zeros(u_dim,1);             % control input

k = 0;                          % system discrete state index
samlping_cnt = 0;               % counter for the next sampling
io_cnt = 0;                 % time for the next control input
t = 0;                          % current time

t_trace = [];
x_trace = [];
u_trace = [];
y_trace = [];

% system model
plant = zpk(-10, [10 + 20i, 10 - 20i], 1);
plant = tf(plant);

% convert to state space model
[A, B, C, D] =  tf2ss(plant.num{1},plant.den{1});
plant_ss = ss(A, B, C, D);

% design LQR controller gain
SYS = plant_ss;
Q = [20 0; 0 20];
R = [0.1];
N = [0];
[K,S,e] = lqr(SYS, Q, R, N);
ctrl.k = K;
ctrl.x = 0;
ctrl.ref = 1;

% closed-loop tf
sys_cl = ss(A - B * ctrl.k, B, C, D);

for i = 0:simu.step:simu.time
    % update measurement
    if (samlping_cnt == 0)
        ctrl.x = x;
         
        sampling_delay = ceil(g_period / simu.step);
        sampling_jitter = randi([0, 0]); 
        samlping_cnt = sampling_delay + sampling_jitter;  % 0.0833 is the Wc
        
        io_latency = floor(g_latency / simu.step);
        io_jitter = floor(0.000 / simu.step);
        io_cnt = randi([io_latency, io_latency + io_jitter]);  % control delay
        
        %subplot(2,1,2)
        %scatter(t, 1, 'b+')
        %hold on;
    end
    
    % update control
    % only update 'u' by the control interval
    if (io_cnt == 0) 
        u = ctrl.ref * 50 - ctrl.k * ctrl.x;
        %scatter(t, 1, 'rx')
        %hold on;
    end
    
    % update system model
    % iteratively ode solver
    x_dot = A * x + B * u;
    x = x + x_dot * simu.step;
    y = C * x;
    t = t + simu.step;
    
    t_trace = [t_trace;t];
    y_trace = [y_trace;y];
    u_trace = [u_trace;u];
    x_trace = [x_trace;x'];
    
    % update index and counter
    samlping_cnt = samlping_cnt - 1;
    io_cnt = io_cnt - 1;
    k = k + 1;
     
end

% subplot(2,1,1)
% stairs(t_trace, y_trace)
% hold on;

% subplot(2,1,2)
% stairs(t_trace, u_trace)
% hold on;
g_period
g_latency
pi_tss = compute_steady_state_time(y_trace, t_trace, 1, 0.02)
pi_j = compute_quadratic_control_cost(x_trace, u_trace, g_period, [1 0; 0 1;], 0, 0)
