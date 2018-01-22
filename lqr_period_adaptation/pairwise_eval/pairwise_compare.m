close all;
rng default  % For reproducibility

pd = makedist('Normal','mu',100,'sigma',10);

x = random(pd,300,1);
figure()
histogram(x,20)

pd = makedist('Normal','mu',103,'sigma',10);
y = random(pd,200,1);
hold on
histogram(y,20)

% generate empirical CDF
[Fi,xi] = ecdf(x);

figure()
stairs(xi,Fi,'r');
%xlim([0 5]); xlabel('x'); ylabel('F(x)');

hold on;
[Fi,xi] = ecdf(y);
stairs(xi,Fi,'r');
%xlim([0 5]); xlabel('x'); ylabel('F(x)');

% K-S test
% [h,p,ks2stat] = kstest2(x,y)

% make pairwise comparison
g = pairwise_div(x, y);

figure()
histogram(g, 50);
