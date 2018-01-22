function N = adddiscsys(N,sysid,sys,inputid,nodeid,Q,R)
% N = adddiscsys(N,sysid,sys,inputid,nodeid)
% N = adddiscsys(N,sysid,sys,inputid,nodeid,Q,R)
%
% Add a discrete-time linear system "sys" to the Jitterbug system N.
% The system will be updated at execution node "nodeid".
% u(k) --> sys --> y(k)
%          x(k)
%
% Arguments:
% N        The Jitterbug system to add this discrete-time system to.
% sysid    A unique ID number for this system (pick any). Used when
%          referred to from other systems. 
% sys      A discrete-time LTI system in state-space or transfer
%          function form, or a double/matrix (interpreted as a static
%          gain transfer function). Internally, the system will be
%          converted to state-space form.
% inputid  A vector of system IDs. The outputs of the corresponding
%          systems will be used as inputs to this system. The number
%          of inputs in this system must equal the total number of
%          outputs in the input systems. A negative inputid
%          specifies that the corresponding system's STATE should
%          be used instead of its output. An inputid of zero
%          specifies that the input should be taken from the NULL
%          system (which has a scalar output equal to zero).
% nodeid   The timing node where this discrete-time system should be
%          executed. If you want the same system to be executed in
%          further nodes, use adddiscexec.
%
% Optional arguments:
% Q        The cost function is [x(k);y(k);u(k)]'*Q*[x(k);y(k);u(k)]
%          (for state-space systems) or [y(k);u(k)]'*Q*[y(k);u(k)]
%          (for transfer-function systems).
%          NOTE: The input cost is really defined on whatever signal
%          is used as input. If the input system is continuous, the
%          continuous cost (NOT sampled) will be calculated. If you
%          really want the sampled cost, insert a sampling
%          discrete-time system in between.
% R        The noise covariance matrix. Added each time the system
%          is updated. Note that noise may also enter the system
%          from the output nose of another system.
%
% Any optional arguments can be left as [] for default values.

% Sanity checks
if (nargin < 5)
  error('To few arguments to function: N = adddiscsys(N,sysid,sys,inputid,nodeid)');
end

origclass = class(sys);
switch origclass
 case 'ss'
 case 'tf'
 case 'zpk'
 case 'double'
  sys = tf(sys); % convert constant gain to transfer function
  sys.Ts = -1;
  origclass = 'tf';
 otherwise
  error(['System class ' origclass ' not supported. SYS must be' ...
		    ' either ss, tf, zpk, or double.']);
end

if ~isdt(sys)
  error('System is not discrete time.');
end

if (sys.Ts ~= -1) & (abs(sys.Ts-N.dt*N.period)>1e-6*sys.Ts)
  warning('System sample time is ignored.')
end

if ~isproper(sys)
  error('System is not proper.');
end

if hasdelay(sys)
  warning('System delay is ignored.');
end

sys = ss(sys);
A = sys.a;
B = sys.b;
C = sys.c;
D = sys.d;

n = size(A,2); % nbr of states
p = size(C,1); % nbr of outputs
r = size(B,2); % nbr of inputs

totsize = n+p+r;
outinsize = p+r;

if (nargin < 6 | isempty(Q))
  Q = zeros(totsize);
else
  switch origclass
   case 'ss'
    if (size(Q,1) ~= totsize | size(Q,2) ~= totsize)
      error(['For state-space systems, the cost Q should be a matrix' ...
	     ' punishing all states, outputs, and inputs:' ...
	     ' [x;y;u]^T*Q*[x;y;u].'])
    end
   case {'tf','zpk'} 
    if (size(Q,1) ~= outinsize | size(Q,2) ~= outinsize)
      error(['For transfer function systems, the cost Q should be' ...
	     ' matrix punishing all outputs and inputs: [y;u]^T*Q*' ...
	     ' [y;u].'])
    else
      xyutoyu = blkdiag(eye(p),eye(r));
      xyutoyu = [zeros(size(xyutoyu,1),n) xyutoyu ];
      Q = xyutoyu'*Q*xyutoyu;
    end
  end
end

totsize = n+p;
outinsize = p+r;

if (nargin < 7 | isempty(R))
  R = zeros(totsize);
else
  switch origclass
   case 'ss'
    if (size(R,1) ~= totsize | size(R,2) ~= totsize)
      error(['For state-space systems, the noise R should be a' ...
	     ' (n+p)*(n+p) matrix, where n is the number of states' ...
	      ' and p is the number of outputs.'])
    end
   case {'tf','zpk'}
    if (size(R,1) == r)
      %% Alternative syntax added by AC 2006-04-20:
      %% interpret r*r matrix as input noise only
      R = blkdiag(R,zeros(p));
    end
    if (size(R,1) ~= outinsize | size(R,2) ~= outinsize)
      error(['For transfer function systems, the noise R should be either' ... 
	     ' a (r+p)*(r+p) matrix, where r is the number of inputs' ...
	      ' and p is the number of outputs; or a r*r matrix,' ...
	       ' where r is the input of inputs'])
    else
      xutoyu = blkdiag(B,eye(p));
      R = xutoyu*R*xutoyu' + blkdiag(zeros(n),D*R(1:r,1:r)*D');
      %% Bugfix by AC 2004-08-03: added term for direct term noise
    end
  end
end

S = struct('id',sysid,'type',2, 'sysoption', 0);
S.A = A;
S.B = B;
S.C = C;
S.D = D;
S.Q = Q;
S.R2 = R;
S.inputid = inputid;
S.samplenode = nodeid;
S.outputs = max(size(C,1),size(D,1));
S.origclass = origclass;
N.systems = {N.systems{:} S};
