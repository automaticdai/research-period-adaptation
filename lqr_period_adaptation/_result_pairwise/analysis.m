close all;

idx = 1;
j = [];
t = [];
label = {};

for i = 40:5:100
   filename = sprintf('tss_%d.mat', i);
   load(filename);
   j = [j j_a'];
   t = [t tss_a'];
   ecdf(j_a); hold on;
   
   % add to label
   period_str = sprintf('%d ms', i);
   label{idx} = period_str;
   idx = idx + 1;
end

legend(label)

figure()
boxplot(j)
set(gca,'xtick',1:size(label,2), 'xticklabel',label) 
title('Control Cost')

figure()
boxplot(t)
set(gca,'xtick',1:size(label,2), 'xticklabel',label) 
title('Steady-state Time')