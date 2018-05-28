function [ pipi ] = predict( period )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    filename = ['pi_mc_uniform_' num2str(period / 100) 'ms'];
    load(filename)
    pipi = pi.IAE';
end
