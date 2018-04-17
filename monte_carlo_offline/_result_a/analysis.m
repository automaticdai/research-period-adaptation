% performance with different BCRT and WCRT range
% data filename: pi_BCRT_WCRT.mat
% uniform distribution and normal distribution
% all normalized to 1

close all


load('pi_0_0.mat')

ideal_y1 = pi.y1(1);
ideal_y2 = pi.y2(1);


figure()
load('pi_0_0.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

load('pi_1_1.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))

load('pi_0_1.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

ylim([0.9,1])
title('BCRT = 0, WCRT = 1, uniform distributed')



figure()
load('pi_0_0.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

load('pi_0_2.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

load('pi_2_2.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

ylim([0.9,1])
title('BCRT = 0, WCRT = 2, uniform distributed')



figure()
load('pi_0_0.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

load('pi_norm_0_2.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

load('pi_2_2.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

ylim([0.9,1])
title('BCRT = 0, WCRT = 2, normal distributed')