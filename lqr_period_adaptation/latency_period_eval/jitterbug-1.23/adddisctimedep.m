function N = adddisctimedep(N,sysid,sys,timestep,nodeid)
% N = adddisctimedep(N,sysid,sys,timestep)
% N = adddisctimedep(N,sysid,sys,timestep,nodeid)
%
% Makes the system dynamics of the discrete-time system with ID
% "sysid" time-dependent. The new system model "sys" will be used
% for all total delays greater than or equal to timestep*delta
% seconds (unless another definition overrides for longer delays).
%
% Arguments:
% N         The Jitterbug system.
% sysid     The ID of a previously defined discrete-time system.
% sys       A discrete-time LTI system describing the new dynamics.
%           To ensure that the same state vector is used
%           internally, both this and the original system should be
%           given in state-space form.
% timestep  The system dynamics will be used for all total delays
%           tau >= timestep*delta since the first node.
%
% Optional arguments:
% nodeid    For what execution/timing node (as defined by adddiscsys
%           and adddiscexec) the time-dependency should be added
%
% NOTE: It is not possible to change the noise or the cost of the
%       system.

if (nargin < 4)
  error('To few arguments to function: N = adddisctimedep(N,sysid,sys,timestep,[nodeid])');
end

if nargin == 4
  nodeid = [];
end

% find the unique timing node

base = 0;
for s = 1:length(N.systems)
  if (N.systems{s}.id == sysid & N.systems{s}.type == 2)
    if isempty(nodeid)
      if base == 0
	base = s;
      else
	error(sprintf(['There is more than one execution of system %d defined'...
		      ' - specify a timing node using ''nodeid''.'], sysid));
      end
    else
      if N.systems{s}.samplenode == nodeid
	base = s;
      end
    end
  end
end


if (base == 0)
  if nodeid == []
    error(sprintf(['No discrete-time system with id %d found. Define using '...
		   'adddiscsys first.'], sysid));
  else
    error(sprintf(['No discrete-time system with id %d executing in node %d found. Define using adddiscsys first.'], sysid, nodeid));
  end
end



if (isempty(sys))
  error(['An LTI system must be supplied.']);
else
  if (sys.Ts == 0)
    error(sprintf('System is not discrete time.', sysid));
  end
  if (sys.Ts ~= -1 & sys.Ts ~= N.period*N.dt)
    warning('System sample time ignored')
  end
  if (N.systems{base}.origclass ~= 'ss')
    error(sprintf(['The base system %d is not on '...
		   'state-space form, so changing system definition '...
		   'lead to unpredictable results.'], sysid));
  end
  system = ss(sys);
  A = sys.a;
  B = sys.b;
  C = sys.c;
  D = sys.d;
  if (~((size(A,1) == size(N.systems{base}.A,1)) & ...
	(size(A,2) == size(N.systems{base}.A,2)) & ...
	(size(B,1) == size(N.systems{base}.B,1)) & ...
	(size(B,2) == size(N.systems{base}.B,2)) & ...
	(size(C,1) == size(N.systems{base}.C,1)) & ...
	(size(C,2) == size(N.systems{base}.C,2)) & ...
	(size(D,1) == size(N.systems{base}.D,1)) & ...
	(size(D,2) == size(N.systems{base}.D,2))))
    error(sprintf(['The system is not of the same size as in the' ...
		   ' original system %d.'], sysid));
  end
end
if (timestep < 0 | round(timestep) ~= timestep)
  error('The timestep must be a non-negative integer.');
end
S = N.systems{base};
% Expand size of matrices if necessary
if (min(min(A==S.A(:,:,end))) == 0)
  if (timestep > size(S.A,3))
    oldsize = size(S.A,3);
    for t = oldsize:timestep;
      S.A(:,:,t) = S.A(:,:,oldsize);
    end
  end
  S.A(:,:,timestep+1) = A;
end
if (min(min(B==S.B(:,:,end))) == 0)
  if (timestep > size(S.B,3))
    oldsize = size(S.B,3);
    for t = oldsize:timestep;
      S.B(:,:,t) = S.B(:,:,oldsize);
    end
  end
  S.B(:,:,timestep+1) = B;
end
if (min(min(C==S.C(:,:,end))) == 0)
  if (timestep > size(S.C,3))
    oldsize = size(S.C,3);
    for t = oldsize:timestep;
      S.C(:,:,t) = S.C(:,:,oldsize);
    end
  end
  S.C(:,:,timestep+1) = C;
end
if (min(min(D==S.D(:,:,end))) == 0)
  if (timestep > size(S.D,3))
    oldsize = size(S.D,3);
    for t = oldsize:timestep;
      S.D(:,:,t) = S.D(:,:,oldsize);
    end
  end
  S.D(:,:,timestep+1) = D;
end
N.systems{base} = S;
