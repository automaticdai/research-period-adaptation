% Jitterbug example: kushner.m
% ================================
% Classical example from Kushner and Tobias (1969), "On the stability of
% randomly sampled systems", TAC 14:4, that shows that sampling jitter
% can have a stabilizing effect.

s = tf('s');
P = 6/((s+1)*(s+2));  % The plant
C = -1;               % The controller/sampler/ZOH (unit negative feedback)

R1 = 1;               % Input noise
R2 = 0;               % Measurement noise
Q = diag([1 0]);      % Cost function: J = E y^2

h = 1.42;             % Sampling period

dt = h/50;            % Time-grain

jvec = 0:dt:h/2;
Jvec = [];

for j=jvec,
  
  Ptau = ones(1,1+round(j/dt));    % Uniform sampling delay between 0 and j
  Ptau = Ptau/sum(Ptau);
  N = initjitterbug(dt,h);         % Initialize Jitterbug
  N = addtimingnode(N,1,Ptau,2);   % Add node 1 (the periodic node)
  N = addtimingnode(N,2);          % Add node 2
  N = addcontsys(N,1,P,3,Q,R1,R2); % Add sys 1 (P), input from sys 3
  N = adddiscsys(N,2,1,1,1);       % Add sys 2 (C), input from sys 1, exec in 1 
  N = adddiscsys(N,3,C,2,2);       % Add sys 2 (C), input from sys 2, exec in 2 
  N = calcdynamics(N);             % Calculate the internal dynamics
  J = calccost(N)                  % Calculate the cost
  Jvec = [Jvec; J];
end
  
plot(jvec,Jvec)
axis([0 1 0 200])

xlabel('Sampling jitter')
ylabel('Cost')
