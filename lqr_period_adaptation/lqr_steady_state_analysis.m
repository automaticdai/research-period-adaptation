% lqr_steady_state_analysis.m
% Xiaotian Dai
% University of York
% Segment reference signals and find corresponding steady state time.
% Use for analysis results from `mpc_period_with_abitary_reference.m`

addpath('../../Toolbox/')

%% initialization
r_end = 0;
tss_a = [];
h = mpc_param.Ts;


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

    % if tss = -1 means did not reach steady-state
    tss_a = [tss_a tss];
end


%% plot and save result
boxplot(tss_a, h);
i = i + 1;

%filename = sprintf('tss_%0.2f.mat', h);
%save(filename,'tss_a','h');
