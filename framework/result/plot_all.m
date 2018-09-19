
for i = 1:7
    filename = ['d' num2str(i)];
    load(filename)
    
    if (i > 4)
        j = i + 0.5;
    else
        j = i;
    end
    
	subplot(2,4,j)
    
    plot(fw_traces.period / 1000, fw_traces.pip, 'r^-');
    hold on;
    plot(fw_traces.period / 1000, fw_traces.pip_mc, 'bx-');

    title(['E_' num2str(i)])
    xlabel('Period (ms)')
    ylabel('PI')
    
    xlim([10 30])
    ylim([0.5 1.02])

end