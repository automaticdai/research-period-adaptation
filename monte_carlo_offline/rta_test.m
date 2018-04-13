taskset = [0  70  120     0;
           1  80 1210  1210;
           2  20 2030  2030;
           3  20 1520  1520;
           4  30 2020  2020;
           5 100 2000  2000];

kernel_time = 10 * 10^-6;
[bcrt, wcrt] = rta(taskset);

bcrt_a = bcrt .* kernel_time;
wcrt_a = wcrt .* kernel_time;