
ri_a = [];
x = [];

load('ri_afbs_10ms')
ri_a = [ri_a;ri];
x = [x; 10 * ones(numel(ri), 1)];


load('ri_afbs_11ms')
ri_a = [ri_a;ri];
x = [x; 11 * ones(numel(ri), 1)];


load('ri_afbs_12ms')
ri_a = [ri_a;ri];
x = [x; 12 * ones(numel(ri), 1)];


load('ri_afbs_13ms')
ri_a = [ri_a;ri];
x = [x; 13 * ones(numel(ri), 1)];


load('ri_afbs_14ms')
ri_a = [ri_a;ri];
x = [x; 14 * ones(numel(ri), 1)];


load('ri_afbs_15ms')
ri_a = [ri_a;ri];
x = [x; 15 * ones(numel(ri), 1)];



boxplot(ri_a, x)
xlabel('Period (unit: 1 ms)')
ylabel('Response Time (unit: 10 us)')