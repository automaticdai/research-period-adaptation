% Jitterbug example: robustlqg.m
% ================================
% Comparison of no delay compensation, compensation for average delay, and
% compensation assuming a known delay distribution (robust design).
% The delay varies randomly between 0 and taumax. We sweep 0 <= taumax <= h.

s = tf('s');
P = 1/(s^2-1);                     % The process (inverted pendulum)

R1c = 1;                           % Continuous-time input noise
R2 = 0.01;                         % Discrete-time measurement noise
Qc = diag([1 0.01]);               % Continuous cost J = E(y^2 + 0.001*u^2)

h = 0.5;                           % Sampling period
dt = h/20;                         % Time granularity

clf
hold on

taumaxvec = 0:dt:h;
colvec = {[0 0 1],[1 0 0],[0 0.7 0]};

for mode = 1:3
  mode
  Jvec = [];
  
  for taumax = taumaxvec
    
    n = round(taumax/dt)+1;
 
    switch mode
     case 1
      tau = 0;                         % No delay compensation
     case 2
      tau = taumax/2;                  % Compensation for average delay
     case 3
      tau = [[0:dt:taumax]' ones(n,1)/n];   % Compensation for uniform random delay
    end
    
    S = eye(1);                        % Sampler system
    CA = lqgdesign(P,Qc,R1c,R2,h,tau); % LQG controller

    Ptau = ones(1,n)/n;                % Uniform random delay in [0,taumax]

    N = initjitterbug(dt,h);           % Initialize Jitterbug
    N = addtimingnode(N,1,Ptau,2);     % Add node 1 (the periodic node)
    N = addtimingnode(N,2);            % Add node 2
    N = addcontsys(N,1,P,3,Qc,R1c,R2); % Add sys 1 (P), input from sys 3
    N = adddiscsys(N,2,S,1,1);         % Add sys 2 (S), input from 1, exec in 1
    N = adddiscsys(N,3,CA,2,2);        % Add sys 3 (CA), input from 2, exec in 2
    N = calcdynamics(N);               % Calculate the internal dynamics
    J = calccost(N)                    % Calculate the cost
    Jvec = [Jvec J];
  
  end
  
  plot(taumaxvec,Jvec,'Color',colvec{mode});
  
end
hold off

set(gca,'Box','on')
axis([0 h 0 4])
xlabel('Maximum delay')
ylabel('Cost')
legend('No delay compensation','Average-delay design','Robust design',2)

