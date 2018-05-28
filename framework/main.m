% -------------------------------------------------------------------------
% main.m
% Main Framework - Period Adaptation
% Xiaotian Dai
% University of York
% -------------------------------------------------------------------------
% Example of a single experiment. Used data are pre-calculated.
% -------------------------------------------------------------------------

addpath('D:\Projects\git\period-adaptation\data\dataset_b\logs')
addpath('D:\Projects\git\period-adaptation\data\dataset_b\mc')


%% experiment configurations
% framework parameters
fw.conf.ph = 1;                       % prediction horizon
fw.conf.init_period = 1000;           % initial task period is 10 ms
fw.conf.step_size = 100;              % period change step in 1 ms

fw.conf.alphad = 0.20;                % degradation factor
fw.conf.ci = 0.99;                    % decision confidence interval
fw.conf.retry_times = 0;              % retry times

% Configuration File
% system dynamics: plant
% controller: ctrl
% taskset: taskset
% mc configuration: conf

% traces
%fw.iteration


%% algorithm starts here
fw.iteration = 1;
fw.period = fw.conf.init_period;

% make the first prediction
fw.pi_mc = predict(fw.period);

% make the first obesrvation
fw.pi_afbs = observe(fw.period);
fw.j0 = predict_expectation(fw.pi_mc, 0, fw.conf.ci);

fprintf('======================================= \r');
fprintf('Degradation Factor = %f \r', fw.conf.alphad);
fprintf('Decision Boundary = %f \r', fw.conf.ci);

while (true)
    fprintf('------------------------------------ \r')
    fprintf('Iteration: %d \r', fw.iteration)
    fprintf('------------------------------------ \r')
    % bias prediction
    % update model
    [fw.bias, ~] = bias_estimation(fw.pi_afbs, fw.pi_mc);
    fprintf('Bias: %f \r', fw.bias);
    
    % predict next PI for (T + delta_T)
    fw.period = fw.period + fw.conf.step_size;
    fw.pi_mc = predict(fw.period);
    
    % make decision based on predictions: continue?
    fw.j_threshold = fw.j0 / (1 - fw.conf.alphad);
    fw.j_expected = predict_expectation(fw.pi_mc, fw.bias, fw.conf.ci);
    
    fprintf('Estimated: %f \r', fw.j_expected);
    
    if (fw.j_expected > fw.j_threshold)
        % stop as expectation is violated
        sprintf('[End] Due to below expectation \r');
        break;
    else
        % continue and make action, so the system will running at T+delta_T
        % observe system @ T+delta_T
        fw.pi_afbs = observe(fw.period);
        fw.j_actual = predict_expectation(fw.pi_afbs, 0, fw.conf.ci);
        fprintf('Actual: %f \r', fw.j_actual);
        
        % check: PI satisfied??
        if (fw.j_actual > fw.j_threshold)
            % violation
            sprintf('[End] Due to run-time violation \r');
            break;
        else
            % commit the change
            % continue to make next prediction
        end
    end
    
    fw.iteration = fw.iteration + 1;
    
end
