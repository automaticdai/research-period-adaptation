close all;
rng default  % For reproducibility

x = j(:,1);
y = j(:,5);

% generate empirical CDF
[Fi,xi] = ecdf(x);

figure()
stairs(xi,Fi,'b');
%xlim([0 5]); xlabel('x'); ylabel('F(x)');

hold on;
[Fi,xi] = ecdf(y);
stairs(xi,Fi,'g');
%xlim([0 5]); xlabel('x'); ylabel('F(x)');

% K-S test
% [h,p,ks2stat] = kstest2(x,y)

% make pairwise comparison
g = pairwise_div(y, x);

figure()
[Fi,xi] = ecdf(g);
stairs(xi,Fi,'r');


figure()
histogram(g, 50);
