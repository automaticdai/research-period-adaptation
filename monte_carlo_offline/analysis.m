close all


load('./result/pi_0_0.mat')

ideal_y1 = pi.y1(1);
ideal_y2 = pi.y2(1);


figure()
load('./result/pi_0_0.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on


load('./result/pi_1_1.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))


load('./result/pi_0_1.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

ylim([0.9,1])




figure()
load('./result/pi_0_0.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on


load('./result/pi_0_2.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on


load('./result/pi_2_2.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on
ylim([0.9,1])



figure()
load('./result/pi_0_0.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on


load('./result/pi_norm_0_2.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on


load('./result/pi_2_2.mat')
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on
ylim([0.9,1])