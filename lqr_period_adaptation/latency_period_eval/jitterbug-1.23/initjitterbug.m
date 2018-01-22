function N = initjitterbug(delta,h)
% N = initjitterbug(delta,h)
%
% Initialize a new Jitterbug system.
%
% Arguments:
% delta     The time grain (in seconds). The computations in
%           Jitterbug are completely based on this discretization.
%           Computations and memory scale inversely proportionally
%           to delta.
% h         The period of the system (in seconds). Specify 0 if the
%           system should be aperiodic.
%
% Return values:
% N         The Jitterbug system which must be passed to all other functions.

if (nargin < 2)
  error(['Too few arguments to function N = initjitterbug(delta,h).']);
end

if (delta <= 0)
  error('The tick size must be positive.');
end

period = round(h/delta);

N = struct('systems',0,'nodes',0,'dt',delta,'period',period);
N.systems = cell(1,0);
N.nodes = cell(1,0);
