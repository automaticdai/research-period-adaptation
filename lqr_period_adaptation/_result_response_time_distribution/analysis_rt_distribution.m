
% int task_config[TASK_NUMBERS][5] = {
% {0,   7,  12, 0, 0},
% {1,   8, 121, 0, 0},
% {2,   2, 203, 0, 0},
% {3,   2, 152, 0, 0},
% {4,   3, 202, 0, 0},
% {5,   1,   1, 0, 0},
% };

% C_i = 1.0 ms
% Fixed C_i(s)!

plot_number = 5;
scale = 0.1;
number_of_bins = 20;
x_limit = [1.5 6.5];

a = load('log_rt_100.txt');
b = load('log_rt_105.txt'); 
c = load('log_rt_110.txt');
d = load('log_rt_115.txt');
e = load('log_rt_120.txt');

subplot(plot_number,1,1)
histogram(a .* scale, number_of_bins, 'FaceColor', 'r', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 100ms')

subplot(plot_number,1,2)
histogram(b .* scale, number_of_bins, 'FaceColor', 'g', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 105ms')

subplot(plot_number,1,3)
histogram(c .* scale, number_of_bins, 'FaceColor', 'b', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 110ms')

subplot(plot_number,1,4)
histogram(d .* scale, number_of_bins, 'FaceColor', 'y', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 115ms')

subplot(plot_number,1,5)
histogram(e .* scale, number_of_bins, 'FaceColor', 'c', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 120ms')