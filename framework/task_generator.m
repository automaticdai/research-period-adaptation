% task_generator.m
% generate synthetic task sets

U_bar = 1.0;
Ti_lower = 0.010;
Ti_upper = 1.0;
task_n = 10000;

Ui = zeros(task_n, 1);
Ci = zeros(task_n, 1);
Ti = zeros(task_n, 1);
Di = zeros(task_n, 1);

%% Generate task utilization with UUnifast
Ui = UUniFast(task_n, U_bar);
Ui = Ui';


%% Generate task periods
LA = log10(Ti_lower);
LB = log10(Ti_upper);
Ti = 10 .^ (LA + (LB-LA) * rand(1, task_n));
Ti = Ti';


%% Obtain task computation times
Ci = Ui .* Ti;


%% Put everything into taskset[]
Di = Ti;
taskset = [zeros(task_n, 1), Ci, Ti, Di];

% print
fprintf('\r Generated Taskset: (Pi, Ci, Ti, Di == Ti) \r\r');
disp(taskset);

% show in diagram
f1 = figure();
histogram(Ui, 'Normalization', 'Probability')
title('Utilization')

f2 = figure();
histogram(Ti, 'Normalization', 'Probability')
title('Periods')