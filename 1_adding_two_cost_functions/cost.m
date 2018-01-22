% This experiment explores what could happen for adding two cost function
% together.

%syms x
%f = symfun([x^2, x^4], x);

close all;

%%
figure(1)
t1 = 0.1:1:100;

x = 100 * exp(1) .^(-t1 ./ 10);
plot(t1, x)
hold on;

t2 = 0.1:1:100;
y = 200 * exp(1) .^(-t2 ./ 20) + t2.^1.1 - 3*log(t2 ./ 2);
plot(t2, y)


xrep = repmat(x, [size(y,2), 1]);
y = y';
yrep = repmat(y, [1, size(x, 2)]);
legend('C1','C2')
xlabel('U_i ({C_i}/{T_i})','FontSize',12);
ylabel('Cost','FontSize',12)

%%
figure(2)
z = xrep + yrep;
surf(z)

