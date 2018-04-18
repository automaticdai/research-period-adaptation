% Compare using result from b3 + afbs_10ms

close all;

alpha_level = 0.7;
bin_size = 50;

pi_afbs = load('pi_afbs_10ms');
pi_mc_uni = load('pi_mc_uniform_10ms');
pi_mc_ecdf = load('pi_mc_ecdf_10ms');

subplot(2,1,1)
histogram(pi_afbs.pi.ISE, bin_size, 'FaceAlpha', alpha_level);
hold on;
histogram(pi_mc_uni.pi.ISE, bin_size, 'FaceAlpha', alpha_level);
histogram(pi_mc_ecdf.pi.ISE, bin_size, 'FaceAlpha', alpha_level);
title('ISE')

subplot(2,1,2)
histogram(pi_afbs.pi.IAE, bin_size, 'FaceAlpha', alpha_level);
hold on;
histogram(pi_mc_uni.pi.IAE, bin_size, 'FaceAlpha', alpha_level);
histogram(pi_mc_ecdf.pi.IAE, bin_size, 'FaceAlpha', alpha_level)
title('IAE')