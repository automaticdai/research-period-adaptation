%% Extension of Example 12.16 in ?str?m and Wittenmark (1997)

% Compare the intersample variance between digital LQG controllers
% designed with discrete-time or continuous-time cost functions. Note
% that the average cost is lower for the controller based on the
% continuous-time cost function, although the cost is higher in the
% sampling instants.

P = ss(0,1,1,0);  % integrator

Q1 = 1;
Q2 = 0;
Q = blkdiag(Q1,Q2);
R1 = 1;
R2 = 1;

h = 0.5;
delta = h/20;

%% LQG controller with discrete-time cost function
[Phi,Gamma,C,D] = ssdata(c2d(P,h));
[s,e,L] = dare(Phi,Gamma,Q1,Q2);
sysk = ss(Phi,[Gamma 1],C,[D 0],h);
Obs = kalman(sysk,R1*h,R2);
Hc{1} = lqgreg(Obs,L);

%% LQG controller with continuous-time cost function
Hc{2} = lqgdesign(P,Q,R1,R2,h);

S = 1; % sampler

Jvec = [];
tauvec = 0:delta:h;

for l = 1:2
  Jvec{l} = [];
  for tau=tauvec
    N = initjitterbug(delta,h);
    N = addtimingnode(N,1,[zeros(1,round(tau/delta)) 1],2);
    N = addtimingnode(N,2);
    N = addcontsys(N,1,P,2,[],R1,R2);      % plant
    N = adddiscsys(N,2,Hc{l},1,1);         % controller
    N = adddiscsys(N,3,S,1,2,diag([1 0])); % intersample measurement
    N = calcdynamics(N);
    J = calccost(N)
    Jvec{l} = [Jvec{l} J];
  end
end

plot(tauvec,Jvec{1});
hold on
plot(tauvec,Jvec{2},'--')
hold off

legend('Intersample variance for ctrl based on discrete cost','Intersample variance for ctrl based on continuous cost')

axis([0 0.5 0 2.5])