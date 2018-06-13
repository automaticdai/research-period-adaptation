% compare prediction with actual observations

close all;

%% boxplot
pi_a = [];
x_a = [];

wcrt_a = [];

pi_ref = 0.1032;
pi_ref_mc = 0.1032;

j_max_a = [];

for i = 1000:100:5000
    filename = ['./afbs/pi_afbs_' num2str(i)];
    load(filename)
    
    % observations
    pi_a = [pi_a;(pi.IAE)];
    x_a = [x_a; i/100 * ones(numel(pi.IAE), 1)];
    wcrt_a = [wcrt_a; max(pi.wcrt)];
    j_max_a = [j_max_a; max(pi_a)];
    
    % predictions
    filename = ['./mc/pi_mc_uniform_' num2str(i / 100) 'ms'];
    load(filename)
    
    pi_a = [pi_a;pi.IAE'];
    x_a = [x_a; i/100 * ones(numel(pi.IAE),1) + 0.1];
end

% plot
figure()
boxplot(pi_a, x_a)

set(gca, 'xticklabel', [10:50])
set(gca, 'xtick', [1:2:100] + 0.5)
color = ['c', 'y'];

h = findobj(gca,'Tag','Box');
for j = 1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(mod(j, 2) + 1),'FaceAlpha',.5);
end

 % wcrt
figure()
plot(10:50, wcrt_a, 'x--')
title('WCRT');

% 