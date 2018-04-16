function [ ise_cost ] = compute_ise_control_cost(x_stream, Ts)

ise_cost = 0;

for i = 1: size(x_stream, 1)
    
x = x_stream(i,:)';

% Calculate the quadratic cost of a control system

P1 = x .^ 2;

ise_cost = ise_cost + (P1) * Ts;

end


end
