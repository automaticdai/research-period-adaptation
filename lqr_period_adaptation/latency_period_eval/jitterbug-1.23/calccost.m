function [J,P,F] = calccost(N,options)
% [J,P,F] = calccost(N)
%
% With all arguments:
% [J,P,F] = calccost(N,options)
%
% Calculate the stationary variance and cost of the Jitterbug
% system "N". For periodic systems, also compute the (discrete-time)
% spectral densities of all outputs in the periodic node.
%
% If the system is periodic, the solution is calculated
% algebraically, by solving a linear system of equations. If the
% system is aperiodic, an iterative solver is used. 
%
% Arguments:
% N         The Jitterbug system.
% options   For iterative solver, struct with any of the following fields:
%           accuracy   The iterative solver will quit whenever the relative
%                      cost change for one time step is less than
%                      this. Default is 1e-7.
%           horizon    The horizon over which the cost is
%                      averaged for aperiodic systems. 
%                      May be Inf. Default is the
%                      maximum possible time between two
%                      executions of node 1.
%           print      Enable printouts. Default is 1.
%           maxiter    The maximum number of iterations. Default is 5000.
%           maxcost    The maximum cost before stopping. Default is 1e10.
%            
% Return values:
% J         The cost (Inf if unstable)
% P         The steady-state variance in the periodic node (Inf if unstable)
% F         The spectral densities of the outputs (in the order
%           they were defined) as LTI systems:
%           phi(omega) = F(e^(i*omega*h))
%           Use e.g. "bodemag(F{1})" to plot the power spectral
%           density of the output of the first defined system.

% Our state P is the variance of x, i.e. P is of size |x|^2. 
% During one period, P evolves as
%   P(k+1) = sum(prob_i*A_i*P(k)*A_i^T+R_i),               (1)
% where A_i consists of the linear dynamics for the delay
% realization i (with probability prob_i), and R_i corresponds to
% the added variance. 
%
% Since
%   A_i*P(k)*A_i^T+R_i = kron(A_i, A_i)*P_vec              (2)
% where P_vec = reshape(P, size(P,1)*size(P,2),1) i.e. P written as
% a vector, we can write (1) as
%   P_vec(k+1) = Phi*P_vec(k) + R_vec                      (3)
% where Phi = sum(prob_i*kron(A_i,A_i)) and R_vec = sum(prob_i*R_ivec)
% 
% (3) can then be solved for a steady-state solution algebraically.
% If P_steady is positive definite, this is the steady state variance.
% From P_steady, the cost J as well as the spectral density can be
% calculated exactly. 

% N.nodes is described in calcdynamics.m.
S=N.nodes;

% "States" = timing nodes
states = length(S);
period = N.period;
if (period == 0)
  % Use iterative method
  disp(sprintf('System is aperiodic, using iterative method...'));
  if (nargin == 1)
    [J,P] = calccostiter(N);
  else
    [J,P] = calccostiter(N,options);
  end
  F = [];
  return;
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Calculate the steady-state probability to be in each
% timing node at any time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Phi is defined in (3) above. 
Phi = zeros(size(S{1}.A,1)^2,size(S{1}.A,1)^2,states*2,period+1);
% PhiAvg is sum(prob_i*A_i), i.e. the average transfer matrix. This
% is only used to calculate the spectral density.
PhiAvg = zeros(size(S{1}.A,1),size(S{1}.A,1),states*2,period+1);
% R is the average noise variance added (see (3) above).
R = zeros(size(S{1}.A,1),size(S{1}.A,1),states*2,period+1);
J = 0;
% prob is the probability to be in a certain timing node for
% each time step of the periodic execution.
% Even rows are the probability to be in a certain state, and odd
% rows are the probability to be waiting for the next state (this
% is done so that the full Markov graph does not have to be expanded).
prob = zeros(states*2,period+1);
prob(1,1) = 1; % All probability in the beginning
% The transfer matrix is I
Phi(:,:,1,1) = kron(eye(size(S{1}.A,1)),eye(size(S{1}.A,1)));
PhiAvg(:,:,1,1) = eye(size(S{1}.A,1));
J=0;
for time = 1:period+1
  for s = 1:states
    if (prob((s-1)*2+1,time) > 0 & (~(s == 1 & time==period+1)))
      pr = prob((s-1)*2+1,time);
      Phinext = Phi(:,:,(s-1)*2+1,time)/pr;
      PhiAvgnext = PhiAvg(:,:,(s-1)*2+1,time)/pr;
      Rnext = R(:,:,(s-1)*2+1,time)/pr;
      if (length(S{s}.Ptau) == 0 | s==states) 
	% No probabilistic delay, wait for period
	for tau = 1:period-time;
	  Phinext = kron(S{s}.A,S{s}.A)*Phinext;
	  PhiAvgnext = S{s}.A*PhiAvgnext;
	  Rnext = S{s}.A*Rnext*S{s}.A'+S{s}.R1;
	  Phi(:,:,s*2,time+tau) = Phi(:,:,s*2,time+tau) + ...
	      Phinext*pr;
	  PhiAvg(:,:,s*2,time+tau) = PhiAvg(:,:,s*2,time+tau) + ...
	      PhiAvgnext*pr;
	  R(:,:,s*2,time+tau) = R(:,:,s*2,time+tau) + Rnext*pr;
	  prob(s*2,time+tau) = prob(s*2,time+tau) + pr;
	end
	if (time == period+1)
	  prob((s-1)*2+1,time) = prob((s-1)*2+1,time) - pr;
	else
	  Phinext = kron(S{s}.A,S{s}.A)*Phinext;
	  PhiAvgnext = S{s}.A*PhiAvgnext;
	  Rnext = S{s}.A*Rnext*S{s}.A'+S{s}.R1;
	end
	E = S{1}.E;
	E = E(:,:,min(period+1,size(E,3)));
	R2 = S{1}.R2;
	R2 = R2(:,:,min(period+1,size(R2,3)));
	Phi(:,:,1,period+1) = Phi(:,:,1,period+1)+...
	    (kron(E,E)*Phinext)*pr;
	PhiAvg(:,:,1,period+1) = PhiAvg(:,:,1,period+1)+...
	    (E*PhiAvgnext)*pr;
	R(:,:,1,period+1) = R(:,:,1,period+1)+...
	    (E*Rnext*E'+R2)*pr;
	prob(1,period+1) = prob(1,period+1) + pr;
      else
	% Probabilistic delay
	tau = 1; % Zero delay
	while(tau <= size(S{s}.Ptau,2))
	  for n = 1:size(S{s}.nextprob,1)
	    if (time+tau-1 <= period+1)
	      step = time+tau-1;
	      state = S{s}.next(n);
	      probstate = S{s}.nextprob(n,min(size(S{s}.nextprob,2),time+tau-1));
	    else
	      step = period+1;
	      state = 1;
	      probstate = 1;
	    end
	    if (probstate > 0)
	      E = S{state}.E;
	      E = E(:,:,min(step,size(E,3)));
	      R2 = S{state}.R2;
	      R2 = R2(:,:,min(step,size(R2,3)));
              Ptau = S{s}.Ptau(min(size(S{s}.Ptau,1),time),tau);
	      Phi(:,:,(state-1)*2+1,step) = ...
		  Phi(:,:,(state-1)*2+1,step) + ...
		  (kron(E,E)*Phinext)...
		  *Ptau*prob((s-1)*2+1,time)*probstate;
	      PhiAvg(:,:,(state-1)*2+1,step) = ...
		  PhiAvg(:,:,(state-1)*2+1,step) + ...
		  (E*PhiAvgnext)...
		  *Ptau*prob((s-1)*2+1,time)*probstate;
	      R(:,:,(state-1)*2+1,step) = ...
		  R(:,:,(state-1)*2+1,step) + ...
		  (E*Rnext*E'+R2)*...
		  Ptau*prob((s-1)*2+1,time)*probstate;
	      prob((state-1)*2+1,step) = ...
		  prob((state-1)*2+1,step) + ...
		  Ptau*prob((s-1)*2+1,time)*probstate;
	      pr = pr - Ptau*prob((s-1)*2+1,time)*probstate;
	    end
	  end
	  if (tau > 1) % In-between-nodes 
	    if (time+tau-1 >= period+1)
	      % In last period
	    else
	      Phi(:,:,s*2,time+tau-1) = Phi(:,:,s*2,time+tau-1) + Phinext*pr;
	      PhiAvg(:,:,s*2,time+tau-1) = PhiAvg(:,:,s*2,time+tau-1)+PhiAvgnext*pr;
	      R(:,:,s*2,time+tau-1) = R(:,:,s*2,time+tau-1) + Rnext*pr;
	      prob(s*2,time+tau-1) = prob(s*2,time+tau-1) + pr;
	    end
	  end
	  if (time+tau-1 < period+1)
	    Phinext = kron(S{s}.A,S{s}.A)*Phinext;
	    PhiAvgnext = S{s}.A*PhiAvgnext;
	    Rnext = S{s}.A*Rnext*S{s}.A'+S{s}.R1;
	  end
	  tau = tau + 1;
	end
	
	% If delay=0, then remove that prob for the first state it 
	% passes in zero time
        Ptau = S{s}.Ptau(min(size(S{s}.Ptau,1),time),1);
	prob(2*(s-1)+1,time) = prob(2*(s-1)+1,time)*(1- Ptau);
	Phi(:,:,2*(s-1)+1,time) = Phi(:,:,2*(s-1)+1,time)*(1-Ptau);
	PhiAvg(:,:,2*(s-1)+1,time) = PhiAvg(:,:,2*(s-1)+1,time)*(1-Ptau);
	R(:,:,2*(s-1)+1,time) = R(:,:,2*(s-1)+1,time)*(1-Ptau);
	if (time == period+1)
	  % If last time, remove all in-between-states prob too
	  prob(2*(s-1)+1,time) = 0;
	  Phi(:,:,2*(s-1)+1,time) = 0*Phi(:,:,2*(s-1)+1,time);
	  PhiAvg(:,:,2*(s-1)+1,time) = 0*PhiAvg(:,:,2*(s-1)+1,time);
	  R(:,:,2*(s-1)+1,time) = 0*R(:,:,2*(s-1)+1,time);
	end
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Calculate the steady-state variance P
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Solve for steady state variance
if (sum(prob(2:end,period+1)) > 10*eps)
  disp('System is not periodic!');
end
% Solve P = Phi*P+R using P = (I-Phi)\R
P = reshape((eye(size(Phi,1))-Phi(:,:,1,period+1))\reshape(R(:,:,1,period+1),size(R,1)^2,1),size(R,1),size(R,1));
% If it fails, use pseudo-inverse instead.
if (isinf(P(1,1)))
  disp('Warning: Using bad precision numerics...');
  P = reshape(pinv(eye(size(Phi,1))-Phi(:,:,1,period+1))*reshape(R(:,:,1,period+1),size(R,1)^2,1),size(R,1),size(R,1));
end
Pnext = reshape(Phi(:,:,1,period+1)*reshape(P,size(R,1)^2,1)+reshape(R(:,:,1,period+1),size(R,1)^2,1),size(R,1),size(R,1));
% Check so that P = Phi*P+R, and that P>=0
if (min(real(eig(P)))/abs(max(real(eig(P)))) < -1e-10 | ...
    max(max(abs(P-Pnext)))/max(max(abs(P))) > 1e-9) 
  % If P not positive definite or Pnext != P
  %P = Inf; % Return "unstable"
  J = Inf;
  %P = Phi(:,:,1,period+1);
  %J = R;
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Calculate the steady-state cost J
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now, calculate cost as J=sum(prob_i*P_steady_i*Q)
for time = 1:period
  % Calculate cost 
  for s = 1:2*states
    pr = prob(s,time);
    Qdt = S{floor((s-1)/2)+1}.Q;
    Pdt = reshape(Phi(:,:,s,time)*reshape(P,size(P,1)*size(P,2),1),size(P,1),size(P,2))+R(:,:,s,time);
    J = J + trace(Qdt*Pdt(1:size(Qdt,1),1:size(Qdt,2))) + ...
	pr*S{floor((s-1)/2)+1}.Qconst;
  end
end
J = J / (N.dt*period);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Calculate the spectral densities of all outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate spectral density for all outputs.
% E(y(k+r)*y(k)') = E(C*A^|r|*x(k)*x(k)'*C') = C*A^|r|*P_steady*C'.
% The z transform of this is 
% phi_yy = sum(C*A^|r|*P_steady*C'*z^r) = 
% sum_r>0 (C*A^r*P_steady*C'*z^r) + 
% sum_r>0 (C*A*r*P_steady*C'*z^-r) + CPC'. 
% This is the z-transform of linear system G:
% phi_yy = G(z)+G(z^-1) where G is defined by
% x(k+1) = A*x(k) + P*C'*u(k)
% y(k)   = C*A*x(k) + 0.5*C*P*C'*u(k)
% That is how the spectral density is calculated.
PhiAvg = PhiAvg(:,:,1,period+1);
F = {};
for s=1:length(N.systems)
  if (~N.systems{s}.sysoption)
    if (isfield(N.systems{s},'outputindex'))
      C = [];
      for t = 1:length(N.systems{s}.outputindex)
	c = zeros(1,size(P,2));
	c(N.systems{s}.outputindex) = 1;
	C = [C;c];
      end
    else
      C = zeros(size(N.systems{s}.C,1),size(P,2));
      C(:,N.systems{s}.stateindex) = N.systems{s}.C;
    end
    
    H=ss(PhiAvg,P*C',C*PhiAvg,0.5*C*P*C',N.dt*N.period)/(2*pi);
    Hz = minreal(tf(H));
    for y=1:size(Hz,1)
      for x = 1:size(Hz,2)
	Hzi = tf(fliplr(Hz.num{y,x}),fliplr(Hz.den{y,x}),N.dt*N.period);
      end
    end
    if (isproper(Hzi))
      H = ss(H)+ss(Hzi);
    else
      H = Hz+Hzi;
    end
    F = {F{:} H};
  end
end
