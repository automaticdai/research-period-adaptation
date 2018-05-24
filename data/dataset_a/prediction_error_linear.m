% analysis_precition_error.m
% requirement for prediction:
% R.a) predictions should match actual measurements, or
% R.b) predcition is more pessimistic than actual measurement
%
% as these are distributions, more precisely we define p(A) is actual and p(B) is the predictions
% C.a) is satisfied if; KS distance between p(A) and p(B) is zero; 
% C.b) is satisfied if: 95% worst-case of p(B) is higher than the worst-case of p(A);
%
% the error correction models are 
% M.a) p(A) = alpha * p(B) + bias;
% M.b) p(A) = alpha * p(B) + N(mean, std);


%% load data
pi_afbs = load('pi_afbs_10ms');
pi_mc_uni = load('pi_mc_uniform_10ms');

% make some tricks
pi_mc_uni.pi.IAE = (2.0 * pi_mc_uni.pi.IAE - 0.01); 

% parameters for histograms
bin_min = min(min(pi_afbs.pi.IAE),min(pi_mc_uni.pi.IAE));
bin_max = max(max(pi_afbs.pi.IAE),max(pi_mc_uni.pi.IAE));
bin_number = 100;
bin_edges = [bin_min:(bin_max - bin_min) / bin_number:bin_max];


%% before
f = figure();
% plot histogram before correction
subplot(2,2,1)
h1 = histogram(pi_afbs.pi.IAE, bin_edges, 'Normalization', 'Probability');
hold on;
h2 = histogram(pi_mc_uni.pi.IAE, bin_edges, 'Normalization', 'Probability');
title('Histogram before correction')

% plot cdf before correction
subplot(2,2,3)
ecdf(pi_afbs.pi.IAE)
hold on;
ecdf(pi_mc_uni.pi.IAE)
title('CDF before correction')


%% error estimation
g = figure();
min_err = 1;
min_bias = 0;

subplot(1,2,1)
for i = -0.10:0.001:0.10
    [h, p, ks_D] = kstest2(pi_mc_uni.pi.IAE + i, pi_afbs.pi.IAE);
    if (ks_D < min_err) 
        min_err = ks_D;
        min_bias = i;
    end
    scatter(i, ks_D, 'bx');
    hold on
end

min_mul_error = 1;
min_mul_bias = 0;

subplot(1,2,2)
for i = 0.95:0.001:1.05
    [h, p, ks_D] = kstest2((pi_mc_uni.pi.IAE + min_bias) .* i, pi_afbs.pi.IAE);
    if (ks_D < min_mul_error) 
        min_mul_error = ks_D;
        min_mul_bias = i;
    end
    scatter(i, ks_D, 'bx');
    hold on
end

set(gcf,'outerposition',get(0,'screensize'));


%% after
figure(f);
corrected_IAE = (pi_mc_uni.pi.IAE + min_bias) .* min_mul_bias;

% plot histogram after correction
subplot(2,2,2)
h1 = histogram(pi_afbs.pi.IAE, bin_edges, 'Normalization', 'Probability');
hold on;
h2 = histogram(corrected_IAE, bin_edges, 'Normalization', 'Probability');
title('Histogram after correction')

% plot cdf after correction
subplot(2,2,4)
ecdf(pi_afbs.pi.IAE)
hold on;
ecdf(corrected_IAE)
title('CDF after correction')

set(gcf,'outerposition',get(0,'screensize'));