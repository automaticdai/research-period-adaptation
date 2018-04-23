
pi_afbs = load('pi_afbs_10ms');
pi_mc_uni = load('pi_mc_uniform_10ms');
pi_mc_ecdf = load('pi_mc_ecdf_10ms');

% test normality of distribution using KS-test
disp('AFBS:')
x = (pi_afbs.pi.IAE - mean(pi_afbs.pi.IAE)) ./ std(pi_afbs.pi.IAE);
[h,p] = kstest(x)

disp('Uniform Ri:')
x = (pi_mc_uni.pi.IAE - mean(pi_mc_uni.pi.IAE)) ./ std(pi_mc_uni.pi.IAE);
[h,p] = kstest(x)

disp('Empirical Ri:')
x = (pi_mc_ecdf.pi.IAE - mean(pi_mc_ecdf.pi.IAE)) ./ std(pi_mc_ecdf.pi.IAE);
[h,p] = kstest(x)


% test if from the same distribution
disp('Uniform v.s. ECDF: ')
[h, p] = kstest2(pi_mc_ecdf.pi.IAE, pi_mc_uni.pi.IAE)