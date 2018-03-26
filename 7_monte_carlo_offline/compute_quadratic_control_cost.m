function [ quad_cost ] = compute_quadratic_control_cost(x_stream, u_stream, Ts, Q1, Q12, Q2)

quad_cost = 0;


for i = 1:numel(u_stream)
    
x = x_stream(i,:)';
u = u_stream(i,:)';

% Calculate the quadratic cost of a control system

P1 = x' * Q1 * x;

if Q12 ~= 0
    P2 = 2 * x' * Q12 * u;
else
    P2 = 0;
end

P3 = u' * Q2 * u;

quad_cost = quad_cost + (P1 + P2 + P3) * Ts;

end


end
