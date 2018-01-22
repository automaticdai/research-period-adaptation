function N = addcontsys(N,sysid,sys,inputid,Q,R1,R2,impulse)
% N = addcontsys(N,sysid,sys,inputid)
% N = addcontsys(N,sysid,sys,inputid,Qc,R1c,R2,impulse)
%
% Add a continuous-time linear system "sys" to the Jitterbug system N.
% u(t) --> sys --> y(t)
%          x(t)
%
% Arguments:
% N        The Jitterbug system to add this continuous-time system to.
% sysid    A unique ID number for this system (pick any). Used when
%          referred to from other systems. 
% sys      A strictly proper continuous-time LTI system in
%          state-space or transfer function (or zpk) form. Internally,
%          the system will be converted to state-space form. If the
%          LTI system has a transport delay of L seconds, the sampled
%          system will have (L/delta*num_inputs) extra states.
% inputid  A vector of system IDs. The outputs of the corresponding
%          systems will be used as inputs to this system. The number
%          of inputs in this system must equal the total number of
%          outputs in the input systems. If an inputid is negative,
%          the corresponding system's STATE will be used instead of
%          its output. An inputid of zero specifies that the input
%          should be taken from the NULL system (which has a scalar
%          output equal to zero).
%
% Optional arguments (assumed zero if not specified):
% Qc       The cost function is [x(t);u(t)]'*Qc*[x(t);u(t)] (for
%          state-space systems) or [y(t);u(t)]'*Qc*[y(t);u(t)]
%          (for transfer-function/zpk systems).
% R1c      The state or input noise covariance matrix.
% R2       The discrete-time measurement noise covariance matrix.
%          Note that measurement noise will only be added when the
%          system is sampled by a discrete-time system. It WILL NOT
%          affect any connected CONTINUOUS-TIME systems. 
% impulse  If non-zero, impulse (rather than ZOH) inputs are assumed.
% Any optional arguments can be left as [] for default values.

% Sanity checks
if nargin < 4
  error('To few arguments to function: N = addcontsys(N,sysid,sys,inputid)');
end
origclass = class(sys);
switch origclass
 case 'ss'
 case 'tf'
 case 'zpk'
  otherwise
  error(['System class ' origclass ' not supported. SYS must be' ...
		    ' either ss, tf, or zpk.']);
end

if ~isct(sys)
  error('System is not continuous time.');
end

if ~isproper(sys)
  error('System is not proper');
end

if hasdelay(sys)
  iodelays = totaldelay(sys);
  if sum(sum(iodelays/iodelays(1,1) ~= ones(size(iodelays))))
    error('All I/O transport delays must be indentical for MIMO systems')
  end
  iodelay = iodelays(1,1);
  L = round(iodelay/N.dt);  % transport delay expressed in dt
  if abs(iodelay/N.dt-L) > 1e-10
    disp(['Warning: System I/O delay will be rounded off to ' num2str(L*N.dt)]) 
  end
  sys.ioDelay = 0*sys.ioDelay;
  sys.InputDelay = 0*sys.InputDelay;
  sys.OutputDelay = 0*sys.OutputDelay;
  if hasdelay(sys); error('Unknown type of delay still present!'); end
else
  L = 0;
end

sys = ss(sys);
A = sys.a;
B = sys.b;
C = sys.c;
D = sys.d;

n = size(A,1);

if (max(max(abs(D))) > eps) 
  error('The continuous system has a direct term, which is not supported.');
else
  D = zeros(size(D));
end
  
totsize = size(A,2)+size(B,2);
outinsize = size(C,1)+size(B,2);

if nargin < 5 | isempty(Q)
  Q = zeros(totsize);
else
  switch origclass
   case 'ss'
    if size(Q,1) ~= totsize | size(Q,2) ~= totsize
      error(['For state-space systems, the cost Q should be a matrix' ...
	     ' punishing all states and inputs: [x;u]^T*Q*[x;u].'])
    end
   case {'tf','zpk'}
    if size(Q,1) ~= outinsize | size(Q,2) ~= outinsize
      error(['For transfer function systems, the cost Q should be a matrix' ...
	     ' punishing all outputs and inputs: [y;u]^T*Q*[y;u].'])
    else
      xutoyu = blkdiag(C,eye(size(B,2)));
      Q = xutoyu'*Q*xutoyu;
    end
  end
end

if nargin < 6 | isempty(R1)
  R1 = zeros(size(A,1));
else
  switch origclass
   case 'ss'
    if size(R1,1) ~= size(A,1) | size(R1,2) ~= size(A,2)
      error(['For state-space systems, the noise R1 should be an' ...
	     ' n*n matrix, where n is the number of states.'])
    end
   case {'tf','zpk'}
    if size(R1,1) ~= size(B,2) | size(R1,2) ~= size(B,2)
      error(['For transfer function systems, the noise R1 should' ...
	     ' be an r*r matrix, where r is the number of inputs.'])
    else
      R1 = B*R1*B';
    end
  end
end

if nargin < 7 | isempty(R2)
  R2 = zeros(size(C,1));
else
  if (size(R2,1) ~= size(C,1) | size(R2,2) ~= size(C,1))
    error(['The noise R2 should be a square matrix the size' ...
	   ' of the number of outputs y.']);
  end
end

if nargin < 8 | isempty(impulse)
	impulse = 0;
end

if impulse > 0 && L > 0
	error('Transport delay AND impulse inputs cannot be handled (yet)')
end

if impulse > 0
	Q1 = Q(1:n,1:n);
	Q12 = Q(1:n,n+1:end);
	Q2 = Q(n+1:end,n+1:end);
	if norm(Q12) > 0
		warning('Cross-terms between x and u ignored!')
	end
	Q = blkdiag(Q1,Q2/(N.period*N.dt)^2);
end


S = struct('id',sysid,'type',1, 'sysoption', 0);

if L > 0 % handle transport delays
  S.A = [A B zeros(size(A,1),size(B,2)*(L-1)); zeros(size(B,2)*L,size(A,2)+size(B,2)+size(B,2)*(L-1))];
  S.B = zeros(size(B,1)+size(B,2)*L,size(B,2));
else 
  S.A = A;
  S.B = B;
end
S.C = [C zeros(size(C,1),size(B,2)*L)];
S.D = D;
S.R1 = blkdiag(R1,zeros(size(B,2)*L,size(B,2)*L));
S.R2 = R2;
S.Q = blkdiag(Q,zeros(size(B,2)*L,size(B,2)*L));
S.L = L;
S.inputid = inputid;
S.outputs = size(C,1);
S.origclass = origclass;
S.impulse = impulse;
N.systems = {N.systems{:} S};

