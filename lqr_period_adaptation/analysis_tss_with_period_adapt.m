% How to:
% copy from command output of afbs -> .txt file
% import variable from txt as 'tt' and 'xx'

% plot steady-state time
subplot(2,1,1)
stairs(tt, xx)

% add a reference line
xlim = get(gca,'xlim');  %Get x range 
hold on
plot([xlim(1) xlim(2)],[0 0],'k')


% plot periods
subplot(2,1,2)
stairs(t, periods(:,7))