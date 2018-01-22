close all; clc; clear;

%% Setup the enviroment
run 'setup_env.m'


%% Process System Model
sys_zpk = zpk([],[-400+80i, -400-80i], [1000]);
sys = tf(sys_zpk);


%% Parameters
T1 = 1000;
T2 = 1000;
T3 = 1000;


%% load and run simulation
sim('simulink_afbs_demo.slx');


%% plot system response
f = figure();
plot(simout_y.time, simout_y.data);
legend('Task 3', 'Task 4', 'Task 5');
title('Control System Response')


%% plot cpu schedule
%f = figure();
%plot_scheduling(simout_schedule.data);


%% calculate utilization
u0 = sum(simout_schedule.data==0);
u1 = sum(simout_schedule.data==1);
u2 = sum(simout_schedule.data==2);
u3 = sum(simout_schedule.data==3);
u4 = sum(simout_schedule.data==4);
u5 = sum(simout_schedule.data==5);
u6 = sum(simout_schedule.data==6);
u = u0 + u1 + u2 + u3 + u4 + u5 + u6;

f = figure();
barh([0 1 2 3 4 5 6],[u0/u; u1/u; u2/u; u3/u; u4/u; u5/u; u6/u]);
a = gca;
a.YTick = ([0 1 2 3 4 5 6]);
a.YTickLabel = ({'Task 0','Task 1','Task 2','Task 3','Task 4','Task 5', 'IDLE'});
title('Task Utilization')


%% plot period adapation
f = figure();
plot(simout_periods.data);
title('Task Periods v.s. Time')
legend({'Task 0','Task 1','Task 2','Task 3','Task 4','Task 5'})


%% Save to PDF (optional)
%h = gcf;
%set(h,'PaperOrientation','landscape');
%set(h,'PaperUnits','normalized');
%set(h,'PaperPosition', [0 0 1 1]);
%print(gcf, '-dpdf', 'test.pdf');
