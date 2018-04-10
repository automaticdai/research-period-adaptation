function [ ise_cost ] = compute_ise_control_cost(x_stream, u_stream, Ts, Q1, Q12, Q2)

ise_cost = 0;

for i = 1:numel(u_stream)
    
x = x_stream(i,:)';
u = u_stream(i,:)';

% Calculate the quadratic cost of a control system

P1 = x .^ 2;

ise_cost = ise_cost + (P1) * Ts;

end


end
