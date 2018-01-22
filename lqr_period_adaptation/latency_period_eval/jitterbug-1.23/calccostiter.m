function [J,Pret] = calccostiter(N,options)
% [J,P] = calccostiter(N)
% [J,P] = calccostiter(N,options)
%
% Calculate steady-state variance and cost for the state when system jumps
% between timing nodes defined by N.nodes. ITERATIVE method.
% This function is used for aperiodic systems.
%
% Returns 
% J -- the cost (Inf if unstable)
% P -- the steady-state variance in node 1 (Inf if unstable)

S=N.nodes;
states = length(S);
period = N.period; % Period or maximum loop length
% Calculate probabilities for delays in states
Pdel = [1];
for s = 1:states
  N.nodes{s}.Pdel = Pdel;
  if (size(N.nodes{s}.Ptau,1) > 1)
    % Conditional prob
    l = size(N.nodes{s}.Ptau,2);
    Pdelnew = zeros(1,length(Pdel)+l);
    for t = 1:length(Pdel)
      Pdelnew(t:t+l-1) = Pdelnew(t:t+l-1) + Pdel(t)*...
	  N.nodes{s}.Ptau(t,:);
    end
    Pdel = Pdelnew;
  else
    if (size(N.nodes{s}.Ptau ,1) > 0)
      Pdel = conv(Pdel,N.nodes{s}.Ptau);
    end
  end
  Pdel = Pdel(1:max(find(Pdel > eps)));
  maxdel = length(Pdel);
end

%maxdel = 100;

if (period == 0)
  preempt = 0;
  period = maxdel-1;
else
  preempt = 1;
end
if (isfield(N,'clockperiod'))
  clockperiod = N.clockperiod;
else
  clockperiod = period;
end

%preempt = 1;

P = zeros(size(S{1}.A,1),size(S{1}.A,1),states*2,period+1,period+1);
prob = zeros(states*2,period+1,period+1);
prob(1,1,1) = 1;

% Default values
acc = 1e-7;
horizon = period;
printout = 1;
maxcost = 1e10;
maxiter = 5000;

if (nargin >= 2)
  if (isfield(options,'accuracy'))
    acc = options.accuracy;
  end
  if (isfield(options,'horizon'))
    horizon = options.horizon;
  end
  if (isfield(options,'print'))
    printout = options.print;
  end
  if (isfield(options,'maxcost'))
    maxcost = options.maxcost;
  end
  if (isfield(options,'maxiter'))
    maxiter = options.maxiter;
  end
end

time = 1;
J = 1e-16;
Jold = 2*J;
Jvec = [];
clock = 0;

while(((abs(Jold-J)/max(Jold,1e-16) > acc | time < 50) & J < maxcost & time < maxiter))
  Jold = J;
  J = 0;
  % Even rows are in-state and odd are between-states
  % Calculate cost for this iteration
  for delay=1:period+1
    for s = 1:2*states;
      P(:,:,s,delay,mod(time-1-1,period+1)+1) = 0;
      pr = prob(s,delay,mod(time-1,period+1)+1);
      Qdt = S{floor((s-1)/2)+1}.Q;
      J = J + trace(Qdt*P(1:size(Qdt,1),...
			  1:size(Qdt,2),s,delay,mod(time-1,period+1)+1)) + ...
	  pr*S{floor((s-1)/2)+1}.Qconst;
    end
  end
  prob(:,:,mod(time-1-1,period+1)+1) = 0;
  % Delay is total delay since we passed node 1
  delay = 1;
  %prob(:,:,mod(time-1,period+1)+1)
  z = 0;
  while (sum(sum(prob(1:2:2*states,:,mod(time-1,period+1)+1))) > eps)
    z = z+1;
    if z > 1000 % Simple (lazy) sanity check
      error('Loop with period 0 detected in timing model');
    end
    for s = 1:states
      pr = prob((s-1)*2+1,delay,mod(time-1,period+1)+1);
      if (pr > eps)
	Pnext = P(:,:,(s-1)*2+1,delay,mod(time-1,period+1)+1)/pr;
	if (size(S{s}.Ptau,2) == 0) % No probabilistic delay, wait for period
	  for tau = 1:period-delay;
	    Pnext = S{s}.A*Pnext*S{s}.A'+S{s}.R1;
	    P(:,:,s*2,delay+tau,mod(time+tau-1,period+1)+1) = ...
		P(:,:,s*2,delay+tau,mod(time+tau-1,period+1)+1) + ...
		Pnext*pr;
	    prob(s*2,delay+tau,mod(time+tau-1,period+1)+1) = ...
		prob(s*2,delay+tau,mod(time+tau-1,period+1)+1) + pr;
	  end
	  Pnext = S{s}.A*Pnext*S{s}.A'+S{s}.R1;
	  P(:,:,1,1,mod(time+period-delay+1-1,period+1)+1) = ...
	      P(:,:,1,1,mod(time+period-delay+1-1,period+1)+1)+...
	      (S{S{s}.next}.E*Pnext*S{S{s}.next}.E'+S{S{s}.next}.R2)*pr;
	  prob(1,1,mod(time+period-delay+1-1,period+1)+1) = ...
	      prob(1,1,mod(time+period-delay+1-1,period+1)+1) + pr;
	else
	  % Probabilistic delay
	  tau = 1; % Zero delay
	  while(tau <= size(S{s}.Ptau,2) & (tau+delay-1 <= period ...
					    | ~preempt))
	    if (prob((s-1)*2+1,delay,mod(time-1,period+1)+1) > eps)
	      for n = 1:size(S{s}.nextprob,1)
		if (size(S{s}.Ptau,1) > 1)
		  ptau = S{s}.Ptau(delay,tau);
		else
		  ptau = S{s}.Ptau(tau);
		end
		next = S{s}.next(n);
		ptau = ptau*S{s}.nextprob(n,min(size(S{s}.nextprob,2),time+tau-1));
		newdelay = delay+tau-1;
		if (next == 1)
		  newdelay = 1;
		end
		if (ptau > eps)
		  P(:,:,(next-1)*2+1,newdelay,mod(time+tau-2,period+1)+1) = ...
		      P(:,:,(next-1)*2+1,newdelay,mod(time+tau-2,period+1)+1) + ...
		      (S{next}.E*Pnext*S{next}.E'+S{next}.R2)...
		      *ptau*prob((s-1)*2+1,delay,mod(time-1,period+1)+1);
		  prob((next-1)*2+1,newdelay,mod(time+tau-2,period+1)+1) = ...
		      prob((next-1)*2+1,newdelay,mod(time+tau-2,period+1)+1) + ...
		      ptau*prob((s-1)*2+1,delay,mod(time-1,period+1)+1);
		  pr = pr - ptau*prob((s-1)*2+1,delay,mod(time-1, ...
							  period+1)+1);
		end
	      end
	      if (tau > 1 & pr > eps) % In-between-nodes 
		P(:,:,s*2,newdelay,mod(time+tau-2,period+1)+1) = ...
		    P(:,:,s*2,newdelay,mod(time+tau-2,period+1)+1) + Pnext*pr;
		prob(s*2,newdelay,mod(time+tau-2,period+1)+1) = ...
		    prob(s*2,newdelay,mod(time+tau-2,period+1)+1) + pr;
	      end
	    end
	    Pnext = S{s}.A*Pnext*S{s}.A'+S{s}.R1;
	    tau = tau + 1;
	  end
	  if (tau <= size(S{s}.Ptau,2) & pr > eps) 
	    % There are delays longer than our period => preempt
	    P(:,:,1,1,mod(time+period-delay+1-1,period+1)+1) = ...
		P(:,:,1,1,mod(time+period-delay+1-1,period+1)+1)+...
		(S{1}.E*Pnext*S{1}.E'+S{1}.R2)*pr;
	    prob(1,1,mod(time+period-delay+1-1,period+1)+1) = ...
		prob(1,1,mod(time+period-delay+1-1,period+1)+1) + pr;
	  end
	end
      end
      P(:,:,(s-1)*2+1,delay,mod(time-1,period+1)+1) = 0;
      prob((s-1)*2+1,delay,mod(time-1,period+1)+1) = 0;
    end
    delay = delay +1;
    if (delay > period+1)
      delay = 1;
    end
  end
  J = J / N.dt;
  Jvec = [J Jvec];
  if (~isinf(horizon))
    Jvec = Jvec(1:(min(length(Jvec),horizon)));
  end
  time = time + 1;
  clock = clock + 1;
  clock = mod(clock, clockperiod);
  if (mod(time,10) == 0 & printout)
    disp(sprintf('Time = %d, Jmean = %d, J = %d', time, mean(Jvec),J));
  end
  J = mean(Jvec);
end

if (J >= maxcost)
  disp('Warning: Maximum cost reached, setting J = Inf.');
  J = Inf;
end
if (time >= maxiter)
  disp('Warning: Maximum number of iterations reached, stopping.');
end

Pret = zeros(size(S{1}.A,1),size(S{1}.A,1),states*2,period,period+1);
probret = zeros(states*2,period,period+1);
for t = 1:period
  for delay=1:period
    for s = 1:2*states;
      Pret(:,:,s,delay,t) = P(:,:,s,delay,mod(time+t-1-1,period+1)+1);
      probret(s,delay,t) = prob(s,delay,mod(time+t-1-1,period+1)+1);
    end
  end
end
