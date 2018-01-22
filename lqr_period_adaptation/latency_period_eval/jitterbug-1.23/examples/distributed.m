% Jitterbug example: distributed.m
% ================================
% Calculate the performance of a distributed control system with
% delays/jitter

scenario = 1;  % 1 = constant delay, 2 = random delay,
               % 3 = random delay + jitter compensation
s = tf('s');
G = 1000/(s^2+s);  % The process
R1 = 1;            % Input noise
R2 = 0;            % Output noise
Q = diag([1 1]);   % J = E(y^2 + u^2)

% Default PD parameters
K = 1.5;
Td = 0.035;

% Gain(delay)-scheduled PD parameters
tauv = [0 0.0035 0.0045 0.0055 0.0065 0.0075];
Kv = [1.5 1.2 1.1 0.98 0.86 0.78];
Tdv = [0.035 0.04 0.042 0.046 0.049 0.052];

hvec = 0.001:0.0005:0.010;
Jmat = [];
for h = hvec
  dt = h/40;
  taumaxvec = 0:2*dt:h;
  for taumax=taumaxvec
    Ptau = zeros(1,round(h/dt)+1);
    if scenario == 1
      Ptau(round(taumax/2/dt)+1) = 1;   % constant delay
    else
      Ptau(1:round(taumax/2/dt)+1) = 1; % random delay
    end
    Ptau = Ptau/sum(Ptau);
    
    H1 = 1;                             % Sampler
    H2 = ss(0,1,K*Td/h,-K*(Td/h+1),-1); % Controller
    H3 = 1;                             % Actuator
    
    N = initjitterbug(dt,h);          % Initialize Jitterbug
    
    N = addtimingnode(N,1,Ptau,2);    % Add node 1
    N = addtimingnode(N,2,Ptau,3);    % Add node 2
    N = addtimingnode(N,3);           % Add node 3
    
    N = addcontsys(N,1,G,4,Q,R1,R2);  % Add sys 1 (G)
    N = adddiscsys(N,2,H1,1,1);       % Add sys 2 (H1) to node 1
    N = adddiscsys(N,3,H2,2,2);       % Add sys 3 (H2) to node 2
    N = adddiscsys(N,4,H3,3,3);       % Add sys 4 (H3) to node 3
    
    if scenario == 3  % jitter compensation
      for k=1:round(taumax/2/dt)
        tau1 = dt*k;       % known delay
        tau2 = taumax/4;   % predicted remaining delay
        t = tau1 + tau2;
        Kt = interp1(tauv,Kv,t,'linear','extrap');
        Tdt = interp1(tauv,Tdv,t,'linear','extrap');
        H2 = ss(0,1,Kt*Tdt/h,-Kt*(Tdt/h+1),-1);
        N = adddisctimedep(N,3,H2,k);  % Make sys 3 (H2) time-dependent
      end
    end
    
    N = calcdynamics(N);       % Calculate the internal dynamics
    J = calccost(N)            % Calculate the cost
    Jmat(find(h==hvec),find(taumax==taumaxvec)) = J;
  end
end

Jmat=Jmat/Jmat(1,1);  % scale plot to 1 in (0,0)
figure
surf(0:5:100,hvec,Jmat)
axis([0 100 hvec(1) hvec(end) 1 3])
caxis([0.7 3])
xlabel('Maximum Delay (in % of h)')
ylabel('Sampling Period h')
zlabel('Cost J')
