% -------------------------------------
% monte_carlo_lsim.m
% Xiaotian Dai
% University of York
% -------------------------------------

%% Simulation outer loop
% Simulation variables
simu.count = 0;     % simulation count

while simu.count < conf.simu_times

simu.count = simu.count + 1;

fprintf('Ti = %f, i = %d \r', task.T, simu.count);

simu.tr = 0;        % release time
simu.ts = 0;        % sampling delay
simu.tf = 0;        % finish time (from sampling to finish)

% initial conditions
g_time = 0;
simu.state = 0;     % simulation state

x0 = zeros(plant.order, 1);

simu.x = x0';
simu.y = C * x0;
simu.u = [0];
simu.t = [0];
simu.ut = [0];

ctrl.x = 0;
ctrl.u = 0;

% Simulation inner loop
i = 0;

while i < 3000
% control maximum simulation length, but why?
    switch simu.state
        case 0
            % s0: task start
            g_time = 0;

            % s0 -> s1: first job release delay
            switch conf.sync_mode
                case 0
                    simu.tr = 0;
                case 1
                    simu.tr = task.T * rand(1);
                case 2
                    simu.tr = task.T;
            end
            
            t = 0:conf.simu_samplingtime:simu.tr;
            noises = wgn(numel(t), 1, conf.noise_level) * conf.noise_on;
            u = ones(numel(t), 1) * ctrl.u + noises;
            x0 = simu.x(end, 1:plant.order)';

            if numel(t) > 1
                [y, t, x] = lsim(plant.model_ss, u, t, x0);

                % save result to simulation container
                simu.x = [simu.x;x];
                simu.y = [simu.y;y];
                simu.u = [simu.u;u];
                simu.t = [simu.t;t + g_time];
            end

            g_time = g_time + simu.tr;
            simu.state = 1;

        case 1
            % s1: task released
            % 

            % s1 -> s2: sampling delay
            % sampling delay is ignored
            simu.ts = 0;
            g_time = g_time + simu.ts;
            simu.state = 2;

        case 2
            % s2: task activated, sampling input
            ctrl.x = simu.x(end, 1:plant.order)';
            ctrl.y = C * ctrl.x;

            % s2 -> s3: task executing
            % sampling response time
            switch (conf.sampling_method)
                case 1
                    simu.tf = sampling_ri_uniform(task.runtime.bcrt, task.runtime.wcrt);
                case 2
                    simu.tf = sampling_ri_norm(task.runtime.bcrt, task.runtime.wcrt);
                case 3
                    simu.tf = sampling_ri_empirical(task.runtime.ri);
            end

            %;
            %;

            t = 0:conf.simu_samplingtime:simu.tf;
            noises = wgn(numel(t), 1, conf.noise_level) * conf.noise_on;
            u = ones(numel(t), 1) * ctrl.u;
            u = awgn(u, conf.noise_level_snr, 'measured');
            
            x0 = simu.x(end, 1:plant.order)';

            if numel(t) > 1
                [y, t, x] = lsim(plant.model_ss, u, t, x0);

                % save result to simulation container
                simu.x = [simu.x;x];
                simu.y = [simu.y;y];
                simu.u = [simu.u;u];
                simu.t = [simu.t;t + g_time];
            end

            simu.state = 3;
            g_time = g_time + simu.tf;

        case 3
            simu.tr = task.T - simu.tf;

            % s3: output & task finished
            ctrl.u = -1 * ctrl.K * ctrl.x + (ctrl.ref * ctrl.N_bar);

            % s3 -> s1
            t = 0:conf.simu_samplingtime:simu.tr;
            noises = wgn(numel(t), 1, conf.noise_level) * conf.noise_on;
            
            u = ones(numel(t), 1) * ctrl.u;
            u = awgn(u, conf.noise_level_snr, 'measured');
            
            x0 = simu.x(end, 1:plant.order)';

            if numel(t) > 1
                [y, t, x] = lsim(plant.model_ss, u, t, x0);

                % save result to simulation container
                simu.x = [simu.x;x];
                simu.y = [simu.y;y];
                simu.u = [simu.u;u];
                simu.t = [simu.t;t + g_time];
            end

            % be ready for the next release
            g_time = g_time + simu.tr;
            simu.state = 1;

            if (g_time > conf.simu_time_max)
                break
            end

        otherwise
            disp('Error: unknown state!');
    end

    %fprintf('%f, state %d \r', g_time, simu.state)
    i = i + 1;
end


% plot result (optional)
if false
    subplot(3,1,1)
    stairs(simu.t, simu.y)
    title('Response')
    hold on;

    subplot(3,1,2)
    stairs(simu.t, simu.x)
    title('States')
    hold on;

    subplot(3,1,3)
    stairs(simu.t, simu.u)
    title('Control Inputs')
    hold on;
end


% analysis
[simu.tss, tss_idx] = compute_steady_state_time(simu.y, simu.t, ctrl.ref, 0.05);
simu.cost = compute_quadratic_control_cost(simu.x(1:tss_idx, :), simu.u(1:tss_idx), conf.simu_samplingtime, Q, N, R);
simu.cost_ise = compute_ise_control_cost(ctrl.ref - simu.y(1:tss_idx), conf.simu_samplingtime);
simu.cost_iae = compute_iae_control_cost(ctrl.ref - simu.y(1:tss_idx), conf.simu_samplingtime);

pi.T   = [pi.T task.T];
pi.Tss = [pi.Tss simu.tss];
pi.J   = [pi.J simu.cost];
pi.IAE = [pi.IAE simu.cost_iae];
pi.ISE = [pi.ISE simu.cost_ise];

end
