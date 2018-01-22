% main.m
% Note: minimize h while make the system stable.
% Author: Xiaotian Dai
% Version: v1.0
close all

syms s
s = tf('s');

% reference model (simple first-order system)
% :time constant: 4s, steady-state: 12s
% :for first-order system
% :response vs tau: 1 tau-63.2, 2 tau-86.5, 3 tau-95.0
Gs_actual = 3 / (4*s + 1);

% actual system model
% :time constant: 6s, steady-state time: 6*3 = 18s
Gs = 3 / (6*s + 1);

% controller parameters
Kp = 2.8; Ti = 1.1; 
%Kp = 10; Ti = 0.8; 
h0 = 0.12;  % (*)  control period
h = h0;

Cs = Kp * (Ti*s + 1) / (Ti*s);
Hsc = feedback(Gs * Cs, 1);

f1 = figure;
f2 = figure;

% plot original response
sim('discreate_control_by_period')
u = input.data;
y = output.data;
t = output.time;
figure(f2)
subplot(2, 1, 1)
plot(t, y, 'r*')
hold on;

subplot(2, 1, 2)
plot(t, u, 'r*')
hold on;
    
% Change period from h0 to 1.5*h0, step size = 1% of h0    
for i = 0:50
    h = h0 + h0 * 0.05 * i;

    % evaluate stability
    Gsd = c2d(Gs, h);
    Csd = c2d(Cs, h);
    Hscd = (Gsd*Csd)/(1 + Gsd*Csd);


    % run simlink
    sim('discreate_control_by_period')
    u = input.data;
    y = output.data;
    t = output.time;

    % performance index
    ss_region_logic = ~(y > 0.95 & y < 1.05);
    ss_region_idx = find(ss_region_logic, 1, 'last');

    pi_ss_time = t(ss_region_idx);
    pi_state_cost = sum((1-y).^2 * h);
    pi_control_cost = sum(u .^ 2 * h);
    pi_quad_cost = pi_state_cost + pi_control_cost;
    %%pi_stability = ;


    %% plot PIs
    figure(f1)
    subplot(4,1,1)
    scatter(h, pi_ss_time, 'bx');
    title('Steady State Time')
    hold on;

    subplot(4,1,2)
    scatter(h, pi_state_cost, 'rx');
    title('State Cost')
    hold on;

    subplot(4,1,3)
    scatter(h, pi_control_cost, 'gx');
    title('Input Cost')
    hold on;

    subplot(4,1,4)
    scatter(h, pi_quad_cost, 'yx');
    title('Quadratic Control Cost')
    hold on;

    %% plot respones
    figure(f2)
    subplot(2, 1, 1)
    plot(t, y, 'b')
    hold on;

    subplot(2, 1, 2)
    plot(t, u, 'b')
    hold on;
end
