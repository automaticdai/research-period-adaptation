global g_Ts

for g_Ts = 0.10:0.10:0.80
    disp(g_Ts)
    run('mpc_period_with_abitary_reference')
    run('mpc_steady_state_analysis')
end