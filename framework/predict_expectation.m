function [j_expected] = predict_expectation(pi_predicted, pi_bias, ci)

[f1, x1] = ecdf(pi_predicted + pi_bias);

% ci must be in [0.0, 1.0]
if (ci > 1.0)
    ci = 1.0;
elseif (ci < 0.0)
    ci = 0.0;
end

i = 1;
while (f1(i) < ci)
   i = i + 1; 
end
j_expected = x1(i);

end