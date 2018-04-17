addpath('E:\Workstation\Git\control-systems-matlab\Toolbox')
close all;

end_time = 150;

load 'Ts_0.20_data.mat'
t  = y.time(1:end_time);
y1 = y.data(1:end_time);
tss1 = compute_steady_state_time(y1, t, 1, 0.02);

load 'Ts_0.25_data.mat'
y2 = y.data(1:end_time);
tss2 = compute_steady_state_time(y2, t, 1, 0.02);

load 'Ts_0.30_data.mat'
y3 = y.data(1:end_time);
tss3 = compute_steady_state_time(y3, t, 1, 0.02);

load 'Ts_0.35_data.mat'
y4 = y.data(1:end_time);
tss4 = compute_steady_state_time(y4, t, 1, 0.02);

load 'Ts_0.40_data.mat'
y5 = y.data(1:end_time);
tss5 = compute_steady_state_time(y5, t, 1, 0.02);


stairs(t, y1); hold on;
stairs(t, y2); hold on;
stairs(t, y3); hold on;
stairs(t, y4); hold on;
stairs(t, y5); hold on;

% autocorrelation
%autocorr(y1, 200)
%autocorr(y2, 200)

% correlation
corr1 = corr(y2, y1)
corr2 = corr(y3, y1)
corr3 = corr(y4, y1)
corr4 = corr(y5, y1)

% covariance
cov(y1, y2)

% dynamic time wraping
%dist = dtw(y1, y2) 