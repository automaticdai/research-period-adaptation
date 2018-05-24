% (not finished)
%bias = 1;
%alpha = 0.1;
%plot(0.1 * x + bias, norm)

pii = pi.IAE;
histogram(pii, 100, 'Normalization', 'Probability');
hold on;


pi_new = [];
v = 0.1;         % variance
sigma = sqrt(v); % standard deviation
mu = 0;          % mean

x = sigma .* randn(1) + mu;


x = linspace(-3 * sigma + mu, 3 * sigma + mu, 100);
norm = normpdf(x, mu, sigma);
%plot(x, norm);

for i = 1:numel(pii)
    for j = 1:numel(x)
        %x = normpdf(j, mu, sigma);
        pi_new = [pi_new pii(i) + norm(j)];
    end
end

histogram(pi_new, 100, 'Normalization', 'Probability')
