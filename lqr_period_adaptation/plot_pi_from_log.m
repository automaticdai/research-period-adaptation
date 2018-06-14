% Read PI data from command output of afbs kernel

%% read data from log file
filename = './logs/log1000.log';
delimiterIn = ',';
headerlinesIn = 1;
A = importdata(filename,delimiterIn,headerlinesIn);

t_stamp = A.data(2:end, 1);
tss = A.data(2:end, 2);
ise = A.data(2:end, 3);
iae = A.data(2:end, 4);
mp = A.data(2:end, 5);
tp = A.data(2:end, 6);


%% plot steady-state time
subplot(5,2,1)
stairs(t_stamp, tss)
title('Steady-state time')

% add a reference line
%xlim = get(gca,'xlim');  %Get x range 
%hold on
%plot([xlim(1) xlim(2)],[0 0],'k')
%hline = refline([0 0.25]);

subplot(5,2,2)
boxplot(tss)


%% plot state cost
subplot(5,2,3)
stairs(t_stamp, ise)
title('State costs (ISE)')

subplot(5,2,4)
boxplot(ise)


subplot(5,2,5)
stairs(t_stamp, iae)
title('State costs (IAE)')

subplot(5,2,6)
boxplot(iae)


%% plot mp
subplot(5,2,7)
stairs(t_stamp, mp)
title('Mp')

subplot(5,2,8)
boxplot(mp)

subplot(5,2,9)
stairs(t_stamp, tp)
title('Tp')

subplot(5,2,10)
boxplot(tp)
