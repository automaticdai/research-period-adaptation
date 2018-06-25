alpha = 1 - [1.0, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3];
ti = [10, 15, 24, 25, 28, 29, 30, 30, 31, 32, 34, 35, 36, 37, 39];

plot(alpha, ti, 'b^--')
xlabel('Degradation Factor \alpha')
ylabel('Terminated Period (ms)')