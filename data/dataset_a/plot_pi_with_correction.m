% compare prediction with actual observations

%% boxplot
pi_a = [];
pi_a_corrected = [];
x_a = [];

pi_afbs_this = [];
pi_mc_this = [];
pi_mc_this_corrected = [];

pi_base = 0.1032;
pi_mc_base = 0.1032;

bias = 0;

for i = 10:19
    filename = ['pi_afbs_' num2str(i) 'ms'];
    filename_mc = ['pi_mc_uniform_' num2str(i) 'ms']; 

    % observations
    load(filename)
    pi_afbs_this = pi.IAE;
    pi_a = [pi_a;(pi_afbs_this)];
    pi_a_corrected = [pi_a_corrected;(pi_afbs_this)]; % no correction for raw data
    x_a = [x_a; i * ones(numel(pi.IAE), 1)];
    
    % predictions
    load(filename_mc)
    pi_mc_this = pi.IAE';
    pi_mc_this_corrected = pi_mc_this + bias;
    pi_a = [pi_a;(pi_mc_this)];
    pi_a_corrected = [pi_a_corrected;(pi_mc_this_corrected)];
    x_a = [x_a; (i + 0.001) * ones(numel(pi.IAE), 1)];
    
    % leave a empty column on boxplot
    pi_a = [pi_a;NaN];
    pi_a_corrected = [pi_a_corrected;NaN];
    x_a = [x_a; i + 0.002];
    
    % bias estimation
    [bias, df_max_min] = prediction_bias_estimation(pi_afbs_this, pi_mc_this)
end

subplot(3,1,1)
boxplot(pi_a, x_a)

subplot(3,1,2)
boxplot(pi_a_corrected, x_a)

% plot degradation factor
subplot(3,1,3)