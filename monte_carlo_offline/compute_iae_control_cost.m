function [ iae_cost ] = compute_iae_control_cost(x_stream, Ts)

iae_cost = 0;

for i = 1: size(x_stream, 1)
    
x = x_stream(i,:)';

% Calculate the quadratic cost of a control system

P1 = abs(x');

iae_cost = iae_cost + (P1) * Ts;

end


end
