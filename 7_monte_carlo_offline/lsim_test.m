% define task model
sys = zpk([],[-10+10j -10-10j],1);
plant.model_ss = ss(sys);

% define simulation parameter
conf.simu_sampling_time = 0.01;


t = [0:conf.simu_samplingtime:1];

u = ones(1, numel(t));
x0 = [0;0];

[y,t,x] = lsim(plant.model_ss, u, t, x0);
stairs(t, y)