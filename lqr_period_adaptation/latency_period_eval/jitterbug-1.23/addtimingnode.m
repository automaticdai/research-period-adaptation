function N = addtimingnode(N,nodeid,Ptau,nextnode,nextprob)
% N = addtimingnode(N,nodeid)
% N = addtimingnode(N,nodeid,Ptau,nextnode)
% N = addtimingnode(N,nodeid,Ptau,nextnodes,nextprobs)
% N = addtimingnode(N,nodeid,Ptau,timedepnextnodes)
%
% Add a timing node to the Jitterbug system N. The delay in the
% node is given by the discrete probability distribution Ptau. The
% next node to be visited can be either deterministic, random, or
% dependent on the total delay since the first node.
%
% NOTE 1: The system must have a node with ID 1. If the system is
%         periodic, this will be the periodic node.
% NOTE 2: If the total delay exceeds the period, the execution will
%         restart in the periodic node (if the system is periodic).
%
% Arguments:
% N          The Jitterbug system to add this timing node to.
% nodeid     The ID of this timing node (a positive integer).
% Ptau       The delay probability vector. Ptau(1) is the prob. of a
%            delay of 0*dt, Ptau(2) is the prob. of a delay of 1*dt,
%            etc. If omitted, the system will stay in this node until
%            the next period. If omitted, the system will stay in this
%            node until the next period. If Ptau is a matrix, each row
%            j specifies the delay probability vector given a previous
%            total delay of j*dt seconds.
% nextnode   The next node to be visited, after the delay in this
%            node has elapsed.
% nextnodes  A vector of possible next nodes to be visited.
% nextprobs  A vector specifying the probabilities for each of the
%            nodes in nextnodes to be visited next.
% timedepnextnodes  A vector of next nodes to be visited depending on
%                   the total delay since the first node (including
%                   the delay in this node).

if (nargin < 2)
  error(['To few arguments to function: N = addexecnode(N, nodeid).']);
end
if (nargin < 3)
  Ptau = [];
end
if (nargin < 4)
  nextnode = nodeid+1;
end
if (nargin < 5)
  nextprob = [];
end
if (isempty(Ptau))
  nextnode = 1;
else
  if size(Ptau,1) == 1 
    if (abs(sum(Ptau)-1) > 10*eps)
      warning('Ptau has been corrected to sum to one')
      Ptau = Ptau/sum(Ptau);
    end
  elseif size(Ptau,1) == 2
    if (sum(Ptau') ~= ones(1,size(Ptau,1)))
      warning('Each row in Ptau must sum to one (not corrected!)')
    end
  end
end

if (isempty(nextprob))
  % Time-based next node
  n.next = unique(nextnode);
  n.nextprob = zeros(length(n.next),length(nextnode));
  for t = 1:length(nextnode)
    n.nextprob(find(n.next == nextnode(t)),t) = 1;
  end
else
  % Markov (random) next node
  if (length(nextnode) ~= length(nextprob))
    error(['If next node is chosen randomly, the nextprobs vector' ...
	   ' must be the same size as the nextnodes vector']);
  end
  n.next = nextnode;
  n.nextprob = reshape(nextprob,length(nextprob),1); 
end

% $$$ if (length(Ptau) > 0 & Ptau(1) > eps)
% $$$   if (min(min(n.next)) <= nodeid)
% $$$     error(['If the delay can be zero, the next nodes must all have' ...
% $$$ 	   ' greater IDs than the current timing node (for lazy' ...
% $$$ 	   ' programmer reasons|avoiding algebraic loops).']);
% $$$   end
% $$$ end
n.Ptau = Ptau;
if (nodeid < 1 | round(nodeid) ~= nodeid)
  error('The node ID must be a positive integer.');
end
if (length(N.nodes) >= nodeid & ~isempty(N.nodes{nodeid}))
  error(sprintf('The node %d is already defined.'), nodeid);
end
N.nodes{nodeid} = n;
