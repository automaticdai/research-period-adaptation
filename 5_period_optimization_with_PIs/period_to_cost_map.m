function [ cost ] = period_to_cost_map(period, x, y)
%Summary of this function goes here
%   Detailed explanation goes here
    cost = y(abs(x - period)<1e-4);
end
