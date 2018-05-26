global g_TaskPeriod

j_cost_a = [];
tss_a = [];

for g_TaskPeriod = 0.010:0.001:0.050
    disp(g_TaskPeriod)
    
    %% run simulation
    run('lqr_period_afbs')
    
    %% read data from log file
%     filename = 'log.txt';
%     delimiterIn = ',';
%     headerlinesIn = 1;
%     A = importdata(filename,delimiterIn,headerlinesIn);
% 
%     t_stamp = A.data(2:end, 1);
%     tss = A.data(2:end, 2);
%     j_cost = A.data(2:end, 3);
%     
%     tss_a = [tss_a, tss];
%     j_cost_a = [j_cost_a, j_cost];
end
