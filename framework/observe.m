function [ pipi ] = observe( period )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    filename = ['pi_afbs_' num2str(period)];
    load(filename)
    pipi = pi.IAE;
end
