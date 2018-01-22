% Project: Period Adaptation
% Author:  Xiaotian Dai, University of York
%
% Description:
% Explore PID controller quadratic cost for different periods, given a user-defined reference input 
% Simulation time granuarity: 0.001s (1ms)

s = tf('s');

%% Model 1: motor position control
J = 0.01;
b = 0.1;
K = 0.01;
R = 1;
L = 0.5;

Gp_m = K/(s*((J*s+b)*(L*s+R)+K^2)); % tf
Gp2_m = zpk(Gp_m);   % zpk tf
Gc_m = tf(100);
Gs_m = feedback(Gp_m, 1); % closed loop tf


%% Model 2: simple platform (first-order)

%Gp2 = 1.2 / (0.9*s + 0.8);
Gp2 = 1 / (s + 1.0);

kp = 10; ki = 5; kd = 0;
Gc2 = kp + ki / s + kd * s;

Gs2 = feedback(Gp2 * Gc2, 1);

Gzp2 = c2d(Gp2, 0.20, 'zoh');
Gzc2 = c2d(Gc2, 0.20, 'zoh');
Gzs2 = zpk(feedback(Gzp2 * Gzc2, 1));

% simulink: for disturbance generator 
simu_noise_power = 0.02;
simu_noise_seed = randi([0,10000],1,1);

% simulink: for system model
simu_Gp = Gp2;

%% call simulink block
%t = 0:0.001:10;
%period = ones(1,size(t,2)) .* 0.01;
T = [];
u_all = [];
y_all = [];

for i = 0.010:0.001:0.010
    % input parameters
    period = i
    
    % start simulation
    simin = [0 period];
    sim('main_system')
    
    % get system output
    t = simout.Time;
    u = simout.Data(:,1);
    y = simout.Data(:,2);
    
    % queue results
    T = [T, i];
    u_all = [u_all, u];
    y_all = [y_all, y];
end


