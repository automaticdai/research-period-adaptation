function [rising_time, peak_time, overshoot, settling_time, ...
    cumulative_error, cumulative_control] = control_performance_evaluate(t, u, y, ref)
%   Detailed explanation goes here
    rising_time = t(find(y > ref * 0.9, 1, 'first')) - t(find(y > ref * 0.1, 1, 'first'));
    peak_time = t(find(y == max(y), 1, 'first'));
    overshoot = max(y) - ref;
    settling_time = t(find(abs(y - ref) > ref * 0.01, 1, 'last'));
    
    cumulative_error = sum((y - ref) .^ 2) * 0.001;
    cumulative_control = sum(u .^ 2) * 0.001;
end
