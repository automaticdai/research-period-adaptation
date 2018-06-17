% compare prediction with actual observations

dataset_mc_path = ['./dataset_d'];
dataset_path = ['./dataset_d5'];

close all;

% plot PIs in dataset
x_a = [];
x_a_afbs = [];

iae_a = [];
ise_a = [];
tss_a = [];
mp_a = [];
tp_a = [];
wcrt_a = [];

j_max_a = [];
j_max_mc_a = [];

pi_ref = 0.1032;
pi_ref_mc = 0.1032;

periods = 1000:100:4000;

for i = periods
    filename = [dataset_path '/afbs/pi_afbs_' num2str(i)];
    load(filename)
    
    % observations
    iae_a = [iae_a;(pi.IAE)];
    ise_a = [ise_a;(pi.ISE)];
    tss_a = [tss_a;(pi.Tss)];
    mp_a = [mp_a;(pi.Mp)];
    tp_a = [tp_a;(pi.Tp)];
    wcrt_a = [wcrt_a; max(pi.wcrt)];
    
    j_max_a = [j_max_a; max(iae_a)];
    
    x_a = [x_a; i/100 * ones(numel(pi.IAE), 1)];
    x_a_afbs = [x_a_afbs; i/100 * ones(numel(pi.IAE), 1)];
    
    % predictions
    filename = [dataset_mc_path '/mc/pi_mc_uniform_' num2str(i / 100) 'ms'];
    load(filename)
    
    iae_a = [iae_a;pi.IAE'];
    x_a = [x_a; i/100 * ones(numel(pi.IAE),1) + 0.1];
end

% plot
figure()
boxplot(iae_a, x_a)

set(gca, 'xticklabel', [periods / 100])
set(gca, 'xtick', [1:2:100] + 0.5)
color = ['c', 'y'];

h = findobj(gca,'Tag','Box');
for j = 1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(mod(j, 2) + 1),'FaceAlpha',.5);
end

% PI worst-case
figure()
plot(periods / 100, 1 - (j_max_a - j_max_a(1)) ./ j_max_a, '--s')
xlabel('Period (unit: ms)')
ylabel('Control Performance (%)')

 % wcrt
figure()
plot(periods / 100, wcrt_a, 'x--')
title('WCRT');

% Mp
figure()
boxplot(mp_a, x_a_afbs)