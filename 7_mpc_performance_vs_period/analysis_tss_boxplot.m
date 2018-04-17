addpath('../../../Toolbox/')

h_array = 0.1:0.1:0.8;
tss_for_plot = [];
u_for_plot = [];
labels = {};

for i = 1:numel(h_array)
    % get stead-state time
    filename = sprintf('%stss_%0.2f.mat', subfolder, h_array(i));
    load(filename);
    
    labelname = sprintf('T = %0.2f', h_array(i));
    labels{i} = labelname;
    
    tss_for_plot = [tss_for_plot, tss_a'];
    
    %subplot(2,1,1)
    %scatter(i .* ones(1, numel(tss_a)), tss_a, 5.0, 'rx'); hold on;
    
    % get control inputs
    filename = sprintf('%s/Ts_%0.2f.mat', subfolder, h_array(i));
    load(filename);
    
    u = abs(u);
    u(u < 1.0) = NaN;
    u_for_plot = [u_for_plot, u];
end

%subplot(2,1,1)
boxplot(tss_for_plot, 'labels', labels, 'Positions', pos, 'Width',0.1)
title('Steady State Time')

%subplot(2,1,2)
%boxplot(u_for_plot, 'labels', labels, 'Positions', pos, 'Width',0.1)
%title('Abnormal Control Signals')
