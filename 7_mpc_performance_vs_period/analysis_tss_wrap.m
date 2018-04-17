subfolder = './noise_0/';
pos = linspace(1, 8, 8);
run('analysis_tss_boxplot')

hold on;

subfolder = './noise_1/';
pos = linspace(1.2, 8.2, 8);
run('analysis_tss_boxplot')

%subfolder = './noise_2/';
%pos = linspace(1.4, 8.4, 8);
%run('analysis_tss_boxplot')

%subfolder = './noise_3/';
%pos = linspace(8, 23, 8)';
%run('analysis_tss_boxplot')

hold off;
