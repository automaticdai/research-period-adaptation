% Jitterbug example: notch.m
% ==========================
% Calculate the performance of a notch filter with lost samples.

% 1=no filter, 2=notch filter, 3=time-varying Kalman filter
for scenario = 1:3
  
p = 0.1;      % Probability of lost sample

s = tf('s');
z = tf('z');

h = 0.1;       % Sampling period

% System generating the good signal
G1 = 100/(s+1)^2;
R1 = 2*pi;     % Input noise variance

% System generating the disturbance
omega = 20;    % Resonance frequency
zeta = 0.001;  % Damping
G2 = 50/(s^2+2*zeta*omega*s+omega^2);
R2 = 2*pi;     % Input noise variance

Samp = [1 1];  % Discrete-time system that samples x + e
Diff = [1 -1]; % Discrete-time system that computes x - xhat

switch scenario,
 case 1,
  disp('No filter')
  % No filter
  Filter1 = 1;
  Filter2 = []; % same dynamics (i.e., none)
  Delay = 1;
 
 case 2,
  disp('Notch filter')
  % Zero-phase notch filter
  a = -0.5/cos(omega*h);
  Filter1 = ss(tf([a 1 a],[1 0 0],h));
  Filter1 = Filter1/dcgain(Filter1);
  Filter2 = []; % same dynamics
  Delay = 1/z;  % The notch filter has a delay of one sample

 case 3,
  disp('Kalman filter')
  % Kalman filter based on simple model of G1 (integrator)
  [a1,g1,c1] = ssdata(ss(-0.00001,15,1,0));
  [a2,g2,c2] = ssdata(G2);
  a = blkdiag(a1,a2);
  g = eye(size(a,1));
  c = [c1 c2];
  r1 = blkdiag(g1*g1',g2*g2');
  r2 = 0;
  phi = ssdata(c2d(ss(a,g,c,0),h));
  kf = lqed(a,g,c,r1/h,r2,h);
  k = phi*kf;
  phio = (phi-k*c);
  gammao = k;
  co = [c1 0*c2]*(eye(size(a,1))-kf*c);
  do = [c1 0*c2]*kf;
  Filter1 = ss(phio,gammao,co,do,h);         % Prediction and correction
  Filter2 = ss(phi,zeros(size(a,1),1),[c1 0*c2],0,-1); % Prediction only
  Delay = 1;
end

delta = h;          % Time-grain = sampling interval
Ptau = [1];         % Zero delay between timing nodes
Q = diag([1 0 0]);  % J = xtilde^2

N = initjitterbug(delta,h);       % Initialize Jitterbug

N = addtimingnode(N,1,Ptau,[2 4],[1-p p]);  % Add node 1
N = addtimingnode(N,2,Ptau,3);              % Add node 2
N = addtimingnode(N,3,Ptau,5);              % Add node 3
N = addtimingnode(N,4,Ptau,5);              % Add node 4
N = addtimingnode(N,5);                     % Add node 5

N = addcontsys(N,1,G1,0,[],R1);      % Add sys 1 (G1)
N = addcontsys(N,2,G2,0,[],R2);      % Add sys 2 (G2)
N = adddiscsys(N,3,Samp,[1 2],2);    % Add sys 3 (Samp) to node 2
N = adddiscsys(N,4,Filter1,3,3);     % Add sys 4 (Filter) to node 3
N = adddiscexec(N,4,Filter2,3,4);    % Add execution of sys 4 to node 4
N = adddiscsys(N,5,Delay,1,1);       % Add sys 5 (Delay) to node 1
N = adddiscsys(N,6,Diff,[5 4],5,Q);  % Add sys 6 (Diff) to node 5

N = calcdynamics(N);    % Calculate internal dynamics
[J,P,F] = calccost(N);  % Calculate cost and spectral densities
J

figure(1)
bodemag(F{1},F{2},F{4},F{6})  % Plot spectra of outputs 1,2,4,6
axis([0.1 pi/h 1e-4 1e6]);
legend('Good Signal','Disturbance','Filter Output','Error');
title('Spectral Density')

if scenario < 3
  sprintf('Press enter to continue...')
  pause
end
end
