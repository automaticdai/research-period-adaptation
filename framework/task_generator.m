% task_generator.m
% generate synthetic task sets

%% Parameters
N = 10;                             % number of tasks
U_bound = N * (power(2, 1/N) - 1);  % utilization boundary
U_bar = 0.5;                        % desired utilization
Ti_lower = 100;                     % taskset period upper bound
Ti_upper = 100000;                  % taskset period lower bound

Ui = zeros(N, 1);
Ci = zeros(N, 1);
Ti = zeros(N, 1);
Di = zeros(N, 1);


%% Generate task utilization with UUnifast
Ui = UUniFast(N, U_bar);
Ui = Ui';

% f1 = figure();
% histogram(Ui, 'Normalization', 'Probability')
% title('Utilization')


%% Generate task periods with log-uniformed distribution
LA = log10(Ti_lower);
LB = log10(Ti_upper);
Ti = 10 .^ (LA + (LB-LA) * rand(1, N));
Ti = Ti';

% f2 = figure();
% histogram(Ti, 'Normalization', 'Probability')
% title('Periods')


%% Calculate task computation times
Ci = Ui .* Ti;


%% Put everything into taskset[]
Di = Ti;
taskset = [zeros(N, 1), Ci, Ti, Di];

% print
fprintf('\r Generated Taskset (Pi, Ci, Ti, Di == Ti): \r\r');
disp(taskset);
