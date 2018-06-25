

i = 1;

filename = ['d' num2str(i)];
load(filename)

plot(fw_traces.period / 1000, fw_traces.pip, 'r^-');
hold on;
plot(fw_traces.period / 1000, fw_traces.pip_mc, 'bx-');

xlabel('Period (ms)')
ylabel('PI')
legend(['Actual'],['Estimated'])
ylim([0.3 1.05])

