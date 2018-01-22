% Gp1 = 1 / (s + 1);
% simu_noise_power = 0.02;
filename = 'cost_ideal.mat';
myVars = {'t','u_all', 'y_all'};
S0 = load(filename, myVars{:});

% Gp2 = 1.2 / (0.9 * s + 0.8);
% simu_noise_power = 0.2;
filename = 'cost_actual.mat';
myVars = {'t','u_all', 'y_all'};
S1 = load(filename, myVars{:});

time = 0:0.001:3;
ref = 1;

pi = [];
for i = 1:numel(S0.t)
    [rising_time, peak_time, overshoot, settling_time, ...
    cumulative_error, cumulative_control] = control_performance_evaluate(time, S0.u_all(:,i), S0.y_all(:,i), ref);
    pi_n = [rising_time; peak_time; overshoot; settling_time; ...
    cumulative_error; cumulative_control];
    pi = [pi, pi_n];
    scatter(S0.t(i), overshoot);
    hold on;
end

%plot(S0.y_all);
%hold on;
%plot(S1.y_all);


%e = (S1.y(:,1) - S0.y(:,1)) .^ 2 + (S1.y(:,2) - S0.y(:,2)) .^ 2;
%plot(e)
%hist(e)


