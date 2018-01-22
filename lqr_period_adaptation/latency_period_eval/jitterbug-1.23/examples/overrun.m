% Jitterbug example: overrun.m
% ============================ 
% Compare three overrun handling methods for a control system with
% delayed samples. The plant to be controlled is an integrator with a
% resonance (a third order system). The controller is an LQG
% controller, designed for the mean time delay. The delay for the
% sample from the plant is uniformly distributed between 0 and
% tau_max, which varies between 0 and 2h.
%
% When a sample is delayed more than one period,
% the controller will:
% Case 1) Not be updated at all
% Case 2) Let its observer run without input
% Case 3) Extend the period until the sample arrives (aperiodic system).
%
% The last case is very computationally intensive as it requires an
% iterative solver.

s = tf('s');

zeta = 0.2;
omega = 1;
G = 1/s/(s^2+2*zeta*omega*s+omega^2); % The process          
Samp = 1;

h = 0.25;
delta = h/20;

Q = diag([1 1]);
R1 = 1;
R2 = 0.001;

clf;
hold on;
for mode = 1:3
  mode
  slots = round(h/delta);
  if mode == 1
    delays = (0:2*slots)/slots;
  else
    delays = (1*slots:2*slots)/slots;
  end
  Jvec = [];

  for delay = delays
    % All three modes do the same thing for delay < 1.
    if (mode < 2 | delay >= 1) 
      Ptau = ones(1,round(delay*slots)+1); % Uniform delay
      Ptau = Ptau/sum(Ptau);
      if (mode == 2)
        if (size(Ptau,2) > slots+1)
          Ptau = [Ptau(1:slots) sum(Ptau(1,slots+1:end))];
        end
      end
      Pwait = zeros(round(slots*delay)+1,slots+1);
      for d = 1:(slots*delay+1)
        if (d > slots+1)
          Pwait(d,1) = 1;
        else
          Pwait(d,slots-d+2) = 1;
        end
      end
      
      % Create optimal controller based on mean delay
      [C,L,Obs,K,Kbar,Gd] = lqgdesign(G,Q,R1,R2,h,delay*h/2);
      C.Ts = -1;
      % Create optimal controller based on observer with no input
      Cnodata = ss(Gd.A-Gd.B*L,Gd.B*0,-L,Gd.D*0,h);
      
      % Add different timing nodes depending on mode.
      options = [];
      if (mode == 3)
        N = initjitterbug(delta,0);       % Aperiodic system
	options.accuracy = 1e-5;
	options.maxcost = 4;    % the plot is limited to J<4 anyway
      else
        N = initjitterbug(delta,h);       % Periodic system
      end 
      if (mode == 2)
        N = addtimingnode(N,1,Ptau,[2*ones(1,round(h/delta)) 3]);
      else
        N = addtimingnode(N,1,Ptau,2);
      end
      if (mode == 3)
        N = addtimingnode(N,2,Pwait,1);
      else
        N = addtimingnode(N,2);
      end
      if (mode == 2)
        N = addtimingnode(N,3);
      end
      
      N = addcontsys(N,1,G,3,Q,R1,R2);    % Add sys 1 (G)
      N = adddiscsys(N,2,Samp,1,1);       % Add sys 2 (Samp) to node 1
      N = adddiscsys(N,3,C,2,2);          % Add sys 3 (C) to node 2
      if (mode == 2)
        N = adddiscexec(N,3,Cnodata,2,3); % Add exec of sys 3 (C) to node 3
      end
      N = calcdynamics(N);                % Calculate internal
                                          % dynamics
      J = calccost(N,options)             % Calculate cost
      Jvec = [Jvec J];
      if J == Inf
        delays = delays(1:find(delays==delay));
        break; % Skip remaining delays
      end
    end
  end
  if (mode == 1)
    plot(delays,Jvec,'b');
    Jvec1 = Jvec;
  elseif (mode == 2)
    plot(delays(find(delays >= 1)),Jvec,'g');
    Jvec2 = Jvec;
  else
    plot(delays(find(delays >= 1)),Jvec,'r');
    Jvec3 = Jvec;
  end
  Jvec = [];
  pause(0);
end
hold off;
legend('Skip sample', 'Update controller without sample', 'Extend period');
xlabel('Maximum delay relative to h');
ylabel('Cost');
axis([0 2 1.5 4])
