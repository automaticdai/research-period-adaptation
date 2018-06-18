


for i = 2:7
    filename = ['d' num2str(i)];
    load(filename)
    
	subplot(3,2,i - 1)
    
    plot(fw_traces.period, fw_traces.pip, 'r^-');
    hold on;
    plot(fw_traces.period, fw_traces.pip_mc, 'bx-');

    title(['E_' num2str(i)])
    xlabel('Period')
    ylabel('PI')
    
    ylim([0.5 1.05])

end