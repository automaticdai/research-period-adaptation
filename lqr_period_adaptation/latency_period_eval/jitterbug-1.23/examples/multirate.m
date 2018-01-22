% Jitterbug example: multirate.m
% ==============================
% Calculate the performance of ordinary/multirate ball & beam controller

s = tf('s');

Gphi = 4.4/s;
Gx = -9.0/s^2;

Q = diag([1 0]);
R1 = 1; 

h = 0.1;
delta = h/2;

K1 = -0.2;
Ti = 10;
Td = 1;
N = 10;
PID1c = -K1*(1+1/Ti/s+s*Td/(1+s*Td/N));  % PID controller

K2 = 4;
PID2 = K2*[1 -1];                        % P controller

PID2s = ss(4);
PID2s.Ts = h;

%% Case 1: cascade controller at period h
disp('Cascade controller at period h, CPU usage = 50%')
PID1 = minreal(c2d(PID1c,h,'matched'));
N = initjitterbug(delta,h);
N = addtimingnode(N,1,[1],2);       % Add node 1
N = addtimingnode(N,2);
N = addcontsys(N,1,Gphi,4,Q,R1);    % Add sys 1 (Gphi)
N = addcontsys(N,2,Gx,1,Q);         % Add sys 2 (Gx)
N = adddiscsys(N,3,PID1,2,1);       % Add sys 3 (PID1) to node 1
N = adddiscsys(N,4,PID2,[3 1],2);   % Add sys 4 (PID2) to node 2
N = calcdynamics(N);                % Calculate internal dynamics
J = calccost(N)                     % Calculate cost
% J = 3.3955

%% Case 2: cascade controller at period h/2
disp('Cascade controller at period h/2, CPU usage = 100%')
PID1 = c2d(PID1c,h/2,'matched');
N = initjitterbug(delta,h/2);
N = addtimingnode(N,1,[1],2);       % Add node 1
N = addtimingnode(N,2);             % Add node 2
N = addcontsys(N,1,Gphi,4,Q,R1);    % Add sys 1 (Gphi)
N = addcontsys(N,2,Gx,1,Q);         % Add sys 2 (Gx)
N = adddiscsys(N,3,PID1,2,1);       % Add sys 3 (PID1) to node 1
N = adddiscsys(N,4,PID2,[3 1],2);   % Add sys 4 (PID2) to node 2
N = calcdynamics(N);                % Calculate internal dynamics
J = calccost(N)                     % Calculate cost
% J = 1.9329

%% Case 3: multirate controller at period h and h/2
disp('Multirate cascade controller at period h & h/2, CPU usage = 75%')
PID1 = c2d(PID1c,h,'matched');
N = initjitterbug(delta,h);
N = addtimingnode(N,1,[1],2);       % Add node 1
N = addtimingnode(N,2,[0 1],3);     % Add node 2
N = addtimingnode(N,3);             % Add node 3
N = addcontsys(N,1,Gphi,4,Q,R1);    % Add sys 1 (Gphi)
N = addcontsys(N,2,Gx,1,Q);         % Add sys 2 (Gx)
N = adddiscsys(N,3,PID1,2,1);       % Add sys 3 (PID1) to node 1
N = adddiscsys(N,4,PID2,[3 1],2);   % Add sys 4 (PID2) to node 2
N = adddiscexec(N,4,[],[3 1],3);    % Add exec of sys 4 (PID2) to node 3
N = calcdynamics(N);                % Calculate internal dynamics
J = calccost(N)                     % Calculate cost
% J = 1.9910
