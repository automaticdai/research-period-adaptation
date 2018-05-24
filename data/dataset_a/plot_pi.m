% compare prediction with actual observations

%% boxplot
pi_a = [];
x_a = [];

pi_ref = 0.1032;
pi_ref_mc = 0.1032;

for i = 10:17
    filename = ['pi_afbs_' num2str(i) 'ms'];
    filename_mc = ['pi_mc_uniform_' num2str(i) 'ms']; 

    % observations
    load(filename)
    pi_a = [pi_a;(pi.IAE)];
    x_a = [x_a; i * ones(numel(pi.IAE), 1)];
    
    % predictions
    load(filename_mc)
    pi_a = [pi_a;(pi.IAE')];
    x_a = [x_a; (i + 0.001) * ones(numel(pi.IAE), 1)];
    
    pi_a = [pi_a;NaN];
    x_a = [x_a; i + 0.002];
end

boxplot(pi_a, x_a)