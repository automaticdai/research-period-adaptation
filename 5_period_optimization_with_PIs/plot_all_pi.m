% Gp1 = 1 / (s + 1);
% simu_noise_power = 0.02;
filename = 'cost_ideal.mat';
myVars = {'T','t','u_all', 'y_all'};
S0 = load(filename, myVars{:});

% Gp2 = 1.2 / (0.9 * s + 0.8);
% simu_noise_power = 0.2;
filename = 'cost_actual.mat';
myVars = {'T','t','u_all', 'y_all'};
S1 = load(filename, myVars{:});

time = 0:0.001:3;
ref = 1;

pi0 = [];

for i = 1:numel(S0.T)
    [rising_time, peak_time, overshoot, settling_time, ...
    cumulative_error, cumulative_control] = control_performance_evaluate(time, S0.u_all(:,i), S0.y_all(:,i), ref);
    pi_n = [rising_time; peak_time; overshoot; settling_time; cumulative_error; cumulative_control];
    pi0 = [pi0, pi_n];
end

pi1 = [];

for i = 1:numel(S1.T)
    [rising_time, peak_time, overshoot, settling_time, ...
    cumulative_error, cumulative_control] = control_performance_evaluate(time, S1.u_all(:,i), S1.y_all(:,i), ref);
    pi_n = [rising_time; peak_time; overshoot; settling_time; cumulative_error; cumulative_control];
    pi1 = [pi1, pi_n];
end

subplot(2,3,1)
plot(S0.T,[pi0(1,:)',pi1(1,:)'])
title('rising time')

subplot(2,3,2)
plot(S0.T,[pi0(2,:)',pi1(2,:)'])
title('peak time')

subplot(2,3,3)
plot(S0.T,[pi0(3,:)',pi1(3,:)'])
title('overshoot')

subplot(2,3,4)
plot(S0.T,[pi0(4,:)',pi1(4,:)'])
title('settling time')

subplot(2,3,5)
plot(S0.T,[pi0(5,:)',pi1(5,:)'])
title('cumulative error')

subplot(2,3,6)
plot(S0.T,[pi0(6,:)',pi1(6,:)'])
title('cumulative control')






