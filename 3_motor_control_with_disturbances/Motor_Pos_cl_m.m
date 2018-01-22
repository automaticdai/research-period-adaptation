%% Model 1: motor position control
J = 3.2284E-6;
b = 3.5077E-6;
K = 0.0274;
R = 4;
L = 2.75E-6;

s = tf('s');
G_motor = K/(s*((J*s+b)*(L*s+R)+K^2));
zpk(G_motor)


%% parameters for the controller
T1 = 0.040;
T2 = 0.050;

%% Controller Model
kp = 0.8;
ki = 0;
kd = 0;



