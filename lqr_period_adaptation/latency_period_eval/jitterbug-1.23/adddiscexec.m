function N = adddiscexec(N,sysid,sys,inputid,nodeid)
% N = adddiscexec(N,sysid,sys,inputid,nodeid)
%
% Add an execution of a previously defined discrete-time system.
%
% Arguments:
% N        The Jitterbug system.
% sysid    The ID of a previously defined discrete-time system.
% sys      A discrete-time LTI system or [] for the same dynamics
%          as before. To ensure that the same state vector is used
%          internally, both this and the original system should be
%          given in state-space form.
% inputid  A vector of system IDs. The outputs of the corresponding
%          systems will be used as inputs to this system. The number
%          of inputs in this system must equal the total number of
%          outputs in the input systems. A negative inputid
%          specifies that the corresponding system's STATE should
%          be used instead of its output. An inputid of zero
%          specifies that the input should be taken from the NULL
%          system (which has a scalar output equal to zero).
% nodeid   The ID of the timing node where this discrete-time
%          system should be executed again.
%
% NOTE: It is not possible to change the noise or the cost of the
%       system.

if (nargin < 5)
  error('To few arguments to function: N = adddiscexec(N,sysid,sys,inputid,nodeid)');
end

base = 0;
for s = 1:length(N.systems)
  if (N.systems{s}.id == sysid & N.systems{s}.type == 2)
    base = s;
  end
end
if (base == 0)
  error(sprintf(['No discrete-time system with id %d found. Define using '...
		 'adddiscsys first.'],sysid));
end

if isempty(sys)
  A = N.systems{base}.A;
  B = N.systems{base}.B;
  C = N.systems{base}.C;
  D = N.systems{base}.D;
  origclass = N.systems{base}.origclass;
else
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

  if sys.Ts ~= -1 & sys.Ts ~= N.dt*N.period
    warning('System sample time is ignored.')
  end

  if ~isproper(sys)
    error('System is not proper.');
  end

  if hasdelay(sys)
    warning('System delay is ignored.');
  end

  if (N.systems{base}.origclass ~= 'ss')
    error(sprintf(['The base system %d is not in '...
		   'state-space form, so changing system definition '...
		   'can lead to unpredictable results. If you ' ...
		   'want the same system executed at a new' ...
		   ' node, use sys=[]'], sysid));
  end
  
  sys = ss(sys);
  A = sys.a;
  B = sys.b;
  C = sys.c;
  D = sys.d;
  if (min(min((size(A) == size(N.systems{base}.A) & ...
	size(C) == size(N.systems{base}.C) & ...
        size(D) == size(N.systems{base}.D) & ...
        size(B) == size(N.systems{base}.B))))== 0)
    error(sprintf(['The system is not of the same size as in the' ...
		   ' base system %d'], sysid));
  end
end

if (isempty(inputid))
  inputid = N.systems{base}.inputid;
end

S = struct('id',sysid,'type',2, 'sysoption', 1);
S.A = A;
S.B = B;
S.C = C;
S.D = D;
S.Q = 0*N.systems{base}.Q;
S.R2 = N.systems{base}.R2;
S.inputid = inputid;
S.samplenode = nodeid;
S.outputs = max(size(C,1),size(D,1));
S.origclass = origclass;
N.systems = {N.systems{:} S};
