%% compare prediction with actual observations


%% boxplot
pi_a = [];
x_a = [];

pi_ref = 0.1086;
pi_ref2 = 0.1125;

for i = 10:15
    filename = ['pi_afbs_' num2str(i) 'ms'];
    filename_b = ['pi_mc_uniform_' num2str(i) 'ms']; 

    load(filename)
    pi_a = [pi_a;(pi_ref - pi.IAE) ./ pi_ref];
    x_a = [x_a; i * ones(numel(pi.IAE), 1)];
    
    load(filename_b)
    pi_a = [pi_a;(pi_ref2 - pi.IAE') ./ pi_ref2];
    x_a = [x_a; (i + 0.2) * ones(numel(pi.IAE), 1)];
    
    pi_a = [pi_a;NaN];
    x_a = [x_a; i + 0.3];
end

boxplot(pi_a, x_a)