% Compare using result from b3 + afbs_10ms

close all;

hist_alpha_level = 0.7;
hist_bin_size = 50;

pi_afbs = load('pi_afbs_10ms');
pi_mc_uni = load('pi_mc_uniform_10ms');
pi_mc_ecdf = load('pi_mc_ecdf_10ms');

subplot(2,1,1)
histogram(pi_afbs.pi.ISE, hist_bin_size, 'FaceAlpha', hist_alpha_level);
hold on;
histogram(pi_mc_uni.pi.ISE, hist_bin_size, 'FaceAlpha', hist_alpha_level);
histogram(pi_mc_ecdf.pi.ISE, hist_bin_size, 'FaceAlpha', hist_alpha_level);
title('ISE')
legend('AFBS','MC-UNI','MC-ECDF')

subplot(2,1,2)
histogram(pi_afbs.pi.IAE, hist_bin_size, 'FaceAlpha', hist_alpha_level);
hold on;
histogram(pi_mc_uni.pi.IAE, hist_bin_size, 'FaceAlpha', hist_alpha_level);
histogram(pi_mc_ecdf.pi.IAE, hist_bin_size, 'FaceAlpha', hist_alpha_level)
title('IAE')