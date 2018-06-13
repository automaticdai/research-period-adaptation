global g_TaskPeriod

for g_TaskPeriod = 0.010:0.001:0.014
    disp(g_TaskPeriod)
    
    %% run simulation
    run('lqr_period_afbs')
end
