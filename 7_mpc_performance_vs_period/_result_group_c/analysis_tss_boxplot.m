addpath('../../../Toolbox/')

h_array = [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80];
tss_for_plot = [];
u_for_plot = [];
labels = {};

for i = 1:numel(h_array)
    % get stead-state time
    filename = sprintf('tss_%0.2f.mat', h_array(i));
    load(filename);
    
    labelname = sprintf('T = %0.2f', h_array(i));
    labels{i} = labelname;
    
    tss_for_plot = [tss_for_plot, tss_a'];
    
    subplot(2,1,1)
    scatter(i .* ones(1, numel(tss_a)), tss_a, 5.0, 'rx'); hold on;
    
    % get control inputs
    filename = sprintf('Ts_%0.2f.mat', h_array(i));
    load(filename);
    
    u = abs(u);
    u(u < 1.0) = NaN;
    u_for_plot = [u_for_plot, u];
end

subplot(2,1,1)
boxplot(tss_for_plot, 'labels', labels)
title('Steady State Time')

subplot(2,1,2)
boxplot(u_for_plot, 'labels', labels)
title('Abnormal Control Signals')
