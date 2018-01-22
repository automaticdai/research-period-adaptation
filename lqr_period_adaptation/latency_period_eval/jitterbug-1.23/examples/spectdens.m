% Jitterbug example: spectdens.m
% ==============================
% Compute the sensitivity power spectral density with jitter

s = tf('s');
G = 1/s^2;            % The process is a double integrator

h = 0.25;
delta = h/10;

Mvec = [];
delays = (1:round(h/delta))/round(h/delta);
for delay = delays
  Ptau1 = ones(1,delay*round(h/delta)+1); % Uniform delay
  Ptau1 = Ptau1/sum(Ptau1);
  
  Q = diag([1 0.1]);                    % LQG design weights
  R1 = 1;                               
  R2 = 1;
  C = lqgdesign(G,Q,R1,R2,h,h*delay/2); % Design LQG controller
  
  Samp = 1;                             % Sampler system
  R = diag([0 2*pi]);                   % Sampler noise with density 1

  N = initjitterbug(delta,h);           % Initialize Jitterbug
  N = addtimingnode(N,1,Ptau1,2);       % Add node 1
  N = addtimingnode(N,2);               % Add node 2
  N = addcontsys(N,1,G,3);              % Add sys 1 (G)
  N = adddiscsys(N,2,Samp,1,1,[],R);    % Add sys 2 (Samp) to node 1
  N = adddiscsys(N,3,C,2,2);            % Add sys 3 (C) to node 2
  
  N = calcdynamics(N);                  % Calculate internal dynamics
  [J,P,F] = calccost(N);                % Calculate spectral densities
  H = F{2};                             % y is the second output (sys 2)
  w = logspace(-1,log10(pi/h),50);
  M = bode(H,w);
  M = squeeze(M);
  Mvec = [Mvec M];
end
figure
surfl(log10(w),delays,10*log10(Mvec)')
title('Sensitivity power spectral density with jitter');
xlabel('Log frequency');
ylabel('Maximum delay in % of \ith');
zlabel('PSD of sensitibity output [dB]')
