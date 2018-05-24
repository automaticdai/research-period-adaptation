% -------------------------------------------------------------------------
% main.m
% Main Framework - Period Adaptation
% Xiaotian Dai
% University of York
% -------------------------------------------------------------------------
% Example of a single experiment. Used data are pre-calculated.
% -------------------------------------------------------------------------

%% experiment configurations
% framework parameters
framework.conf.prediction_horizon = 1;  %
framework.conf.init_period = 100;
framework.conf.step_size = 100;         % period change step in 0.1 ms

framework.conf.PI_exp = 0.80;
framework.conf.PI_min = 0.70;
framework.conf.decision_confidence = 0.95;
framework.conf.retry_times = 3;


% system dynamics
framework.system = 0;


% taskset
framework.taskset = 0;


% traces
framework.trace = 0;



%% algorithm starts here
pi = observe(1000);

% make predictions using cloud based application
predict(1000);


% make decision based on predictions
if (decision_making())
    % apply change if a positive decision is made
    scheduler_apply_change();
else
    % stop if a negative result is predicted
    stop();
end

% observe the system after the change
observe(1100);

% analysis the consequence of the change from on-line observations
if (analysis_consequence())
    % commit the change if the observations provide positive result
    scheduler_commit_change();
    % update the model based on observations
    update_model();
else
    % stop if a negative result is found
    % a negative result could be an exception of PI_min
    stop();
end
