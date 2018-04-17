
plot_number = 6;
scale = 0.1;
number_of_bins = 20;
x_limit = [1.5 6.5];

a = load('log_rt_115.txt');
b = load('log_rt_116.txt'); 
c = load('log_rt_117.txt');
d = load('log_rt_118.txt');
e = load('log_rt_119.txt');
f = load('log_rt_120.txt');

figure()

subplot(plot_number,1,1)
histogram(a .* scale, number_of_bins, 'FaceColor', 'r', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 115ms')

subplot(plot_number,1,2)
histogram(b .* scale, number_of_bins, 'FaceColor', 'g', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 116ms')

subplot(plot_number,1,3)
histogram(c .* scale, number_of_bins, 'FaceColor', 'b', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 117ms')

subplot(plot_number,1,4)
histogram(d .* scale, number_of_bins, 'FaceColor', 'r', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 118ms')

subplot(plot_number,1,5)
histogram(e .* scale, number_of_bins, 'FaceColor', 'g', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 119ms')

subplot(plot_number,1,6)
histogram(f .* scale, number_of_bins, 'FaceColor', 'b', 'FaceAlpha', 0.3, 'edgecolor','none');
xlim(x_limit)
title('T_i = 120ms')
