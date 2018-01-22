% Performance Margin
% best achievable performance -> maximum margin
% unstable -> negative margin
% marginal stable -> 0 margin

f1 = figure();

for i = 0.001:0.001:0.025
    g_period = i;
    run('hybrid_jitter_lqr.m')
    
    % system specification
    t = 0:simu.step:simu.time;
    spec.upper = 1.05 + exp(-5*t)';
    spec.lower = 0.95 - exp(-5*t)';
    pms = min(spec.upper - y_trace, y_trace - spec.lower);
    pms(pms < 0) = -1000;
    
    %stairs(t_trace, performance_margin)
    PM = sum(pms) * simu.step;
   
    scatter(g_period, PM, 'bx'); hold on;
end

f2 = figure()
plot(t_trace, spec.upper, 'r');
hold on;
plot(t_trace, spec.lower, 'r');
hold on;
plot(t_trace, y_trace);

