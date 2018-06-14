% Read PI data from command output of afbs kernel

%% read data from log file
filename = './logs/log4000.txt';
delimiterIn = ',';
headerlinesIn = 1;
A = importdata(filename,delimiterIn,headerlinesIn);

t_stamp = A.data(2:end, 1);
tss = A.data(2:end, 2);
j_cost = A.data(2:end, 3);


%% plot steady-state time
subplot(2,2,1)
stairs(t_stamp, tss)
title('Steady-state time')

% add a reference line
%xlim = get(gca,'xlim');  %Get x range 
%hold on
%plot([xlim(1) xlim(2)],[0 0],'k')
%hline = refline([0 0.25]);

subplot(2,2,2)
boxplot(tss)


%% plot state cost
subplot(2,2,3)
stairs(t_stamp, j_cost)
title('State costs')

subplot(2,2,4)
boxplot(j_cost)

%% plot periods
%subplot(3,1,3)
%stairs(t, periods(:,2))
%title('Periods')
