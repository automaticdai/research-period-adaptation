% Read PI data from command output of afbs kernel

%% read data from log file
filename = 'log.txt';
delimiterIn = ',';
headerlinesIn = 1;
A = importdata(filename,delimiterIn,headerlinesIn);

t_stamp = A.data(2:end, 1);
tss = A.data(2:end, 2);
j_cost = A.data(2:end, 3);


%% plot steady-state time
subplot(2,1,1)
stairs(t_stamp, tss)

% add a reference line
xlim = get(gca,'xlim');  %Get x range 
hold on
plot([xlim(1) xlim(2)],[0 0],'k')
hline = refline([0 0.25]);
title('Steady-state time')


%% plot state cost
subplot(2,1,2)
stairs(t_stamp, j_cost)
title('State costs')


%% plot periods
%subplot(3,1,3)
%stairs(t, periods(:,2))
%title('Periods')
