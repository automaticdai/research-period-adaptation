% requirement for prediction:
% a) prediction should bound actual measurement, or
% b) predcition is more pessimistic than actual measurement

pi_afbs = load('pi_afbs_10ms');
pi_mc_uni = load('pi_mc_uniform_10ms');

pi_mc_uni.pi.IAE = pi_mc_uni.pi.IAE + 0.0010; 

bin_min = min(min(pi_afbs.pi.IAE),min(pi_mc_uni.pi.IAE));
bin_max = max(max(pi_afbs.pi.IAE),max(pi_mc_uni.pi.IAE));
bin_number = 100;
bin_edges = [bin_min:(bin_max - bin_min) / bin_number:bin_max];

subplot(3,1,1)
h1 = histogram(pi_afbs.pi.IAE, bin_edges, 'Normalization', 'Probability');
hold on;
h2 = histogram(pi_mc_uni.pi.IAE, bin_edges, 'Normalization', 'Probability');

% error estimation

subplot(3,1,2)
h3 = histogram(h2.Values - h1.Values, 20);

subplot(3,1,3)
ecdf(pi_afbs.pi.IAE)
hold on;
ecdf(pi_mc_uni.pi.IAE)
