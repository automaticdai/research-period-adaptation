% lqr_steady_state_analysis.m
% Xiaotian Dai
% University of York
% Segment reference signals and find corresponding steady state time.
% Use for analysis results from `lqr_period_with_abitary_reference.m`

addpath('../../Toolbox/')

global g_Ts;

%% initialization
r_end = 0;
tss_a = [];
j_a = [];

% previous reference
ref_p = 0; 
alpha = 1;

h = g_Ts;


%% start iteration
while true
    r_start = r_end + 1;
    r_head = ref(r_start);
    idx = (r_head == ref(r_start:end));
    r_end = (r_start - 1) + find(~idx, 1) - 1;

    if (isempty(r_end))
        break
    end

    %subplot(2,1,1)
    %plot(r_start:r_end, y(r_start:r_end)); hold on;

    %subplot(2,1,2)
    %plot(r_start:r_end, ref(r_start:r_end)); hold on;

    tss = compute_steady_state_time(y(r_start:r_end), t(r_start:r_end), ref(r_start), 0.05);
    
    alpha = 1.0 / (ref(r_start) - ref_p);
    j = compute_quadratic_control_cost(alpha * (ref(r_start) - y(r_start:r_end)), ...
            u(r_start:r_end), simu.samlping_time, 1, 0, 0);

    % if tss = NaN means the system did not reach steady-state
    tss_a = [tss_a tss];
    j_a = [j_a j];
    
    ref_p = ref(r_start);
end


%% plot and save result
boxplot(tss_a);
boxplot(j_a);
i = i + 1;

filename = sprintf('tss_%d.mat', g_Ts);
save(['./result/' filename], 'tss_a', 'j_a', 'g_Ts');
