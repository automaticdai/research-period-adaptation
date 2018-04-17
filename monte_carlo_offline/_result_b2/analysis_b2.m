%--------------------------------------------------------------------------
% Compare PI with two different response time distributions
% Each dataset is composed of 1,000 samplings of 1 sec simulation, no noise
% G1: empirical distribution
% G2: uniform distribution
%
% Parameters:
% plant.sys = zpk([],[-10+10j -10-10j],100)
% Q = 1, R = 0.1, Ti = 10ms
% *with* sync delay
%
% G1: `ri.mat` is the response-time profile that is used for empirical simulation
% taskset = [0 7 12 0;
%         1  8 121  121;
%         2  2 203  203;
%         3  2 152  152;
%         4  3 202  202;
%         5 10 200  200];
%
% G2: [BCRT WCRT] is set to be 0.001 and 0.006, respectively.
%--------------------------------------------------------------------------

% ideal (Ri == 0)
pi_i.Tss = 0.2063;
pi_i.J = 0.1040;
pi_i.ISE = 0.0718;
pi_i.IAE = 0.1032;

% load data
load('pi_mc_uniform_10ms.mat')
pi_u = pi;
pi_u.Tss = pi_i.Tss ./ pi_u.Tss;
pi_u.J   = pi_i.J   ./ pi_u.J;
pi_u.IAE = pi_i.IAE ./ pi_u.IAE;
pi_u.ISE = pi_i.ISE ./ pi_u.ISE;

load('pi_mc_ecdf_10ms.mat')
pi_e = pi;
pi_e.Tss = pi_i.Tss ./ pi_e.Tss;
pi_e.J   = pi_i.J   ./ pi_e.J;
pi_e.IAE = pi_i.IAE ./ pi_e.IAE;
pi_e.ISE = pi_i.ISE ./ pi_e.ISE;


% uniform
subplot(4,3,1)
histogram(pi_u.J)
title('J: Uniform Distribution')

subplot(4,3,4)
histogram(pi_u.IAE)
title('IAE: Uniform Distribution')

subplot(4,3,7)
histogram(pi_u.ISE)
title('ISE: Uniform Distribution')

subplot(4,3,10)
histogram(pi_u.Tss)
title('Tss: Uniform Distribution')

% empirical
subplot(4,3,2)
histogram(pi_e.J)
title('J: Empirical Distribution')

subplot(4,3,5)
histogram(pi_e.IAE)
title('IAE: Empirical Distribution')

subplot(4,3,8)
histogram(pi_e.ISE)
title('ISE: Empirical Distribution')

subplot(4,3,11)
histogram(pi_e.Tss) %, 'FaceAlpha', 0.7, 'FaceColor', 'b')
%hold on;
%histogram(pi_u.Tss, 'FaceAlpha', 0.7, 'FaceColor', 'g')
title('Tss: Empirical Distribution')

% plot cdf
subplot(4,3,3)
ecdf(pi_u.J)
hold on;
ecdf(pi_e.J)
title('CDF(J)')

subplot(4,3,6)
ecdf(pi_u.IAE)
hold on;
ecdf(pi_e.IAE)
title('CDF(IAE)')

subplot(4,3,9)
ecdf(pi_u.ISE)
hold on;
ecdf(pi_e.ISE)
title('CDF(ISE)')

subplot(4,3,12)
ecdf(pi_u.Tss)
hold on;
ecdf(pi_e.Tss)
title('CDF(Tss)')