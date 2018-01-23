global g_Ts

for g_Ts = 0.10:0.10:0.10
    disp(g_Ts)
    run('lqr_period_with_abitary_reference')
    run('lqr_steady_state_analysis')
end
