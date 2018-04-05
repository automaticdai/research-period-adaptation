% Response Time Analysis for Fixed Priority Scheduling
% input: taskset array, task of interest, format [Pi, Ti, Ci, Di, 0, 0]
% output: [..., BCRT, WCRT]
function taskset_n = rta(taskset)
       
p_idx = 1;
t_idx = 2;
c_idx = 3;
d_idx = 4;
br_idx = 5;
wr_idx = 6;

for i = 1:size(taskset,1)
    task = taskset(i, :);
    
    % solving best-case response time
    taskset(i, br_idx) = taskset(i, c_idx);
    
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
            taskset(i, wr_idx) = omega;
            break;
        else
            % continue
            omega = omega_n;
            % check task starving
            cnt = cnt + 1;
            if (cnt > 1000)
                disp(['Error: Task ', num2str(i), ' is starving!'])
                taskset(i, wr_idx) = inf;
                break;
            end
        end
    end
end

taskset_n = taskset;

end