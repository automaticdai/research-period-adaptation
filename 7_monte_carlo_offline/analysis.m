load('./result/pi_0_0.mat')

ideal_y1 = pi.y1(1);
ideal_y2 = pi.y2(1);

%subplot(3,1,1)
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on


load('./result/pi_1_1.mat')
%subplot(3,1,3)
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))

load('./result/pi_0_1.mat')
%subplot(3,1,2)
boxplot(ideal_y1 ./ pi.y1, round(pi.x, 3))
hold on

