pi_afbs = load('pi_afbs_10ms');
pi_mc_uni = load('pi_mc_uniform_10ms');

subplot(2,1,1)
histogram(pi_afbs.pi.IAE, 40)
hold on;
histogram(pi_mc_uni.pi.IAE, 40)


subplot(2,1,2)
ecdf(pi_afbs.pi.IAE)
hold on;
ecdf(pi_mc_uni.pi.IAE)
