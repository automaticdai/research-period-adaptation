% Compare PIs histogram using different response time model

close all;

hist_bin_numbers = 30;
hist_alpha_level = 0.7;

%% load dataset
pi_afbs = load('pi_afbs_10ms');
pi_mc_uni = load('pi_mc_uniform_10ms');
pi_mc_ecdf = load('pi_mc_ecdf_10ms');

ise_upper = max([max(pi_afbs.pi.ISE), max(pi_mc_uni.pi.ISE), max(pi_mc_ecdf.pi.ISE)]);
ise_lower = min([min(pi_afbs.pi.ISE), min(pi_mc_uni.pi.ISE), min(pi_mc_ecdf.pi.ISE)]);
ise_bins = linspace(ise_lower, ise_upper, hist_bin_numbers); 

iae_upper = max([max(pi_afbs.pi.IAE), max(pi_mc_uni.pi.IAE), max(pi_mc_ecdf.pi.IAE)]);
iae_lower = min([min(pi_afbs.pi.IAE), min(pi_mc_uni.pi.IAE), min(pi_mc_ecdf.pi.IAE)]);
iae_bins = linspace(iae_lower, iae_upper, hist_bin_numbers);


%% ISE
subplot(2,1,1)
histogram(pi_afbs.pi.ISE, ise_bins, 'FaceAlpha', hist_alpha_level, 'Normalization', 'probability');
hold on;
histogram(pi_mc_uni.pi.ISE, ise_bins, 'FaceAlpha', hist_alpha_level, 'Normalization', 'probability');
histogram(pi_mc_ecdf.pi.ISE, ise_bins, 'FaceAlpha', hist_alpha_level, 'Normalization', 'probability');
title('ISE')
legend('AFBS','MC-UNI','MC-ECDF')


%% IAE
subplot(2,1,2)
histogram(pi_afbs.pi.IAE, iae_bins, 'FaceAlpha', hist_alpha_level, 'Normalization', 'probability');
hold on;
histogram(pi_mc_uni.pi.IAE, iae_bins, 'FaceAlpha', hist_alpha_level, 'Normalization', 'probability');
histogram(pi_mc_ecdf.pi.IAE, iae_bins, 'FaceAlpha', hist_alpha_level, 'Normalization', 'probability')
title('IAE')