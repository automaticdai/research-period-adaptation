% Response Time Analysis for Fixed Priority Scheduling
% input: taskset array, task of interest, format [Pi, Ti, Ci, Di]
% output: [BCRT, WCRT]
function [bcrt wcrt] = rta(taskset)

p_idx = 1;
c_idx = 2;
t_idx = 3;
d_idx = 4;

task_numbers = size(taskset,1);

bcrt = zeros(task_numbers, 1);
wcrt = zeros(task_numbers, 1);

for i = 1:task_numbers
    task = taskset(i, :);

    % solving best-case response time
    bcrt(i) = taskset(i, c_idx);
    
    % solving worst-case response time
    omega = task(c_idx);
    
    cnt = 0;
    while (true)
        omega_n = 0;
        
        omega_n = omega_n + task(c_idx);
        
        for j = 1:i - 1
            task_hp = taskset(j, :);
            omega_n = omega_n + ceil(omega / task_hp(t_idx)) * task_hp(c_idx);
        end

        if (abs(omega_n - omega) < 1e-5)
            % finish searching
            wcrt(i) = omega;
            break;
        else
            % continue
            omega = omega_n;
            % check task starving
            cnt = cnt + 1;
            if (cnt > 1000)
                disp(['Error: Task ', num2str(i), ' is starving!'])
                wcrt(i) = inf;
                break;
            end
        end
    end
end

end