% -------------------------------------------------------------------------
% main.m
% Main Framework - Period Adaptation
% Xiaotian Dai
% University of York
% -------------------------------------------------------------------------
% Offline run of the method. Used data are pre-calculated.
% -------------------------------------------------------------------------

restoredefaultpath
addpath(['..\data\dataset_d' num2str(iii) '\afbs'])
addpath('..\data\dataset_d1\mc')

%% experiment configurations
% framework parameters
fw.conf.ph = 1;                       % prediction horizon
fw.conf.init_period = 1000;           % initial task period is 15 ms
fw.conf.step_size = 100;              % period change step in 1 ms

fw.conf.alphad = 0.5;                 % degradation factor
fw.conf.ci = 0.90;                    % decision confidence interval
fw.conf.retry_times = 0;              % retry times

% Configuration File
% system dynamics: plant
% controller: ctrl
% taskset: taskset
% mc configuration: conf

% traces
fw.traces.period = [];
fw.traces.pip  = [];
fw.traces.pip_mc = [];
fw.traces.bias = [];


%% algorithm starts here
fw.iteration = 0;
fw.period = fw.conf.init_period;

% make the first prediction
fw.pi_mc = predict(fw.period);

% make the first obesrvation
fw.pi_afbs = observe(fw.period);
fw.j0 = predict_expectation(fw.pi_afbs, 0, fw.conf.ci);
%fw.j0 = 0.0547;

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
    %fw.bias = 0;
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
        fprintf('[End] Due to below expectation \r');
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
            fprintf('[End] Due to run-time violation \r');
            break;
        else
            % commit the change
            % continue to make next prediction
        end
    end
    
    % record traces
    fw.traces.bias =[fw.traces.bias fw.bias];
    fw.traces.period = [fw.traces.period; fw.period * 10];
    
    pip_this = 1 - (fw.j_actual - fw.j0) / fw.j_actual;
    fw.traces.pip = [fw.traces.pip; pip_this];
    
    pip_mc_this = 1 - (fw.j_expected - fw.j0) / fw.j_expected;
    fw.traces.pip_mc = [fw.traces.pip_mc; pip_mc_this];

    fw.iteration = fw.iteration + 1;
    
end

%% plot trace
% figure()
% plot(fw.traces.period, fw.traces.pip, 'r^-');
% hold on;
% plot(fw.traces.period, fw.traces.pip_mc, 'bx-');
% 
% xlabel('Period')
% ylabel('PI')
% legend(['Observed'], ['Predicted'])
% 
% figure()
% plot(1:numel(fw.traces.bias), fw.traces.bias, 'o-');
% xlabel('# of Iteration')
% legend(['bias'])

%% save to file
filename = ['./result/d' num2str(iii)];
fw_traces = fw.traces;
save([filename '.mat'], 'fw_traces')