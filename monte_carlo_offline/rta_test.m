% taskset = [0  70  120   120;
%            1  80 1210  1210;
%            2  20 2030  2030;
%            3  20 1520  1520;
%            4  30 2020  2020;
%            5 100 1000  1000];

       
taskset = [       
     0    42   157   157;
     1    10   215   215;
     2    53   499   499;
     3    87   777   777;
     4    48   801   801;
     5   100  1000  1000;
];

kernel_time = 10 * 10^-6;
[bcrt, wcrt] = rta(taskset);

bcrt_a = bcrt .* kernel_time;
wcrt_a = wcrt .* kernel_time;