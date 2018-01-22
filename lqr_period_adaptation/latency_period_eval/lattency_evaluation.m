ii = 1;
jj = 1;
z = 0;

period_candidate = 0.01:0.0001:0.015;
latency_candidate = 0:0.0001:(0.015 - 0.0005);

for g_period = period_candidate
    ii = 1;
    for g_latency = latency_candidate
       if g_latency < g_period
           run('hybrid_jitter_lqr.m')
           z(ii, jj) = pi_j
       end
       ii = ii + 1;
    end
    jj = jj + 1;
end

z(z==0) = NaN;
surf(period_candidate, latency_candidate, z)
%shading flat 
%shading faceted 
shading interp