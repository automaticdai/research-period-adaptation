

i = 1;
filename = ['d' num2str(i)];
load(filename)

fw_traces.period = [10000; fw_traces.period];
fw_traces.pip = [1.0; fw_traces.pip];

% plot PI_delta
plot(fw_traces.period / 1000, 1 - fw_traces.pip, 'r^-');
hold on;

% plot utilization
u = (1./(fw_traces.period / 1000)) / 0.1;
plot(fw_traces.period / 1000, u, 'bs-');


title(['Utilization and Performance Lose'])
xlabel('Period')
legend(['\Delta{PI}'],['U'])

