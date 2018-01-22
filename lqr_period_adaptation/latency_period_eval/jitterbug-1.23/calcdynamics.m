function N = calcdynamics(N)
% N = calcdynamics(N)
%
% Calculate the total system dynamics for the Jitterbug system N. The
% continuous-time nosie, the continuous-time cost functions and the
% continuous-time systems are sampled with the time grain delta. The resulting
% system description is stored in N.nodes. This function must be called before
% calccost.
%
% Arguments:
% N      The Jitterbug system.

% This function builds the timing node structure N.nodes which is
% used by calccost(). The starting point is the N.systems which is
% a set of linear continuous-time and discrete-time systems which
% are interconnected.
%
% Definition of N.nodes
% ==============================================================
% N.nodes is simple and well defined, and does not have to be
% created from a N.systems description (but this is the default
% method in Jitterbug). N.nodes can be expanded to a Jump Linear
% System (Markov net of different linear dynamics).
%
% State dynamics:
% Let the state of the system (including all subsystems) be x.
% For a certain timing node M, the state evolves as
%
% When entering the execution node M:
% x+(k) = M.E*x(k) + v2    where v2 is white Gaussian noise with
%                          variance M.R2
% While in M:
% x(k+1) = M.A*x(k) + v1   where v1 is white Gaussian noise with
%                          variance M.R1
%
% If any of A, E, R1 or R2 is a three-dimensional matrix, then they
% should be indexed with the total delay from the periodic node (to
% model time-varying dynamics).
%
% The step cost (added to the total cost each time step is)
% x(k)'*M.Q*x(k) + M.Qconst
%
% Timing node dynamics:
% If M.nextprob is not 1, and M.next is a vector of node indices,
% then the next timing node is chosen from M.next with
% probability M.nextprob.
% If M.Ptau is a vector, then M.Ptau(1) represents the probability
% to go to M.next with zero delay, M.Ptau(2) represents the prob.
% for delay 1*delta, etc.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Count states and inputs and build a system-to-state
% index mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Indices into A for the subsystems
ind = zeros(2,length(N.systems));
% Indices into continuous outputs
indcontout = zeros(2,length(N.systems));
states = 0; % # of states
contoutputs = 0;
R1 = [];
idtoindex = []; % Array from subsys ID to index
for s = 1:length(N.systems)
	if (N.systems{s}.id < 1)
		error(sprintf('System ID %d is not >= 1.',N.systems{s}.id));
	end
	if ((length(idtoindex) >= N.systems{s}.id) && ...
			idtoindex(N.systems{s}.id) ~= 0 && ...
			N.systems{s}.sysoption == 0)
		error(sprintf('System ID %d defined twice.', ...
			N.systems{s}.id));
	end
	if (N.systems{s}.sysoption == 0)
		idtoindex(N.systems{s}.id) = s;
	end
	if (N.systems{s}.type == 1) % Continuous
		n = size(N.systems{s}.A,1);
		ind(:,s) = [states+1; states+n];
		indcontout(:,s) = [contoutputs+1;contoutputs+size(N.systems{s}.C,1)];
		N.systems{s}.states = n;
		N.systems{s}.stateindex = ind(1,s):ind(2,s);
		states = states + n;
		contoutputs = contoutputs + size(N.systems{s}.C,1);
		R1 = blkdiag(R1,N.systems{s}.R1);
	end
	if (N.systems{s}.type == 2) % Discrete
		if (N.systems{s}.sysoption == 0) % A first definition of this system
			n = size(N.systems{s}.A,1)+max(size(N.systems{s}.C,1),...
				size(N.systems{s}.D,1));
			ind(:,s) = [states+1; states+n];
			N.systems{s}.states = n;
			N.systems{s}.stateindex = [states+1:states+size(N.systems{s}.A,1)];
			N.systems{s}.outputindex = [states+size(N.systems{s}.A,1)+1:states+n];
			states = states + n;
			% R1 is continuous noise, so don't add discrete noise here
			R1 = blkdiag(R1,zeros(n));
		else
			ind(:,s) = ind(:,idtoindex(N.systems{s}.id));
			N.systems{s}.states = N.systems{idtoindex(N.systems{s}.id)}.states;
		end
	end
end
A = zeros(states);
Q = zeros(states);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Check that inputs matches outputs and build cell arrays
% for multiple inputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s = 1:length(N.systems) % Check and fix interconnections
	insys = (N.systems{s}.inputid);
	N.systems{s}.numinputs = size(N.systems{s}.B,2); % save num inputs
	totinputs = 0;
	cellB = {};
	cellD = {};
	% Map whole state vector to states in Q (state, output, input)
	xtou = zeros(N.systems{s}.states,states);
	xtou(:,ind(1,s):ind(2,s)) = eye(N.systems{s}.states);
	for t = 1:length(insys)
		% No of outputs in input system
		if ((insys(t) >= 1 && ...
				(insys(t) < 1 || insys(t) > length(idtoindex) || ...
				idtoindex(insys(t)) == 0))|| ...
				(insys(t) < 0 && ...
				(-insys(t)<1 || -insys(t)>length(idtoindex) || ...
				idtoindex(-insys(t)) == 0)))
			error(sprintf(['System ID %d as referred by system %d '...
				'not exist.']',insys(t),N.systems{s}.id));
		end
		if (insys(t) == 0)
			inputs = 1; % The NULL input system
		elseif (insys(t) >= 1)
			inputs = size(N.systems{idtoindex(insys(t))}.C,1);
		else
			inputs = size(N.systems{idtoindex(-insys(t))}.A,1);
		end
		% Split B into cell array of B's for input systems
		if (size(N.systems{s}.B,2) >= totinputs+inputs)
			B = N.systems{s}.B(:,totinputs+1:totinputs+inputs,:);
			D = N.systems{s}.D(:,totinputs+1:totinputs+inputs,:);
			cellB = { cellB{:} B };
			cellD = { cellD{:} D };
			if (insys(t) == 0)
				% NULL input system
				xtoy = zeros(1,states);
			elseif (insys(t) >= 0)
				in = idtoindex(insys(t));
				if (N.systems{in}.type == 1)
					xtoy = zeros(size(N.systems{in}.C,1),states);
					xtoy(:,ind(1,in):ind(2,in)) = N.systems{in}.C;
				end
				if (N.systems{in}.type == 2)
					if (N.systems{s}.type == 2 && ...
							N.systems{in}.samplenode == N.systems{s}.samplenode)
						error(sprintf(['Execution order undefined: System %d '...
							'uses input from %d which is executed in the '...
							'same timing node. Insert another '...
							'timing node with zero delay to '...
							'specify execution order.']', ...
							N.systems{s}.id, N.systems{in}.id));
					end
					xtoy = zeros(N.systems{in}.outputs,states);
					xtoy(:,ind(1,in):ind(2,in)) = ...
						[zeros(N.systems{in}.outputs,size(N.systems{in}.A,1)) ...
						eye(N.systems{in}.outputs)];
				end
			else
				in = idtoindex(-insys(t));
				xtoy = zeros(size(N.systems{in}.A,1),states);
				xtoy(:,ind(1,in):ind(1,in)-1+size(N.systems{in}.A,1)) = ...
					eye(size(N.systems{in}.A,1));
			end
			xtou = [xtou; xtoy];
		end
		totinputs = totinputs + inputs;
	end
	if (size(N.systems{s}.B,2) ~= totinputs)
		error(sprintf(['System ID %d: number of inputs (%d) does not equal total number of' ...
			' ouputs in input systems (%d).'], N.systems{s}.id, size(N.systems{s}.B,2), totinputs));
	end
	Q = Q + xtou'*N.systems{s}.Q*xtou; % Combined cost of state,
	% outputs and inputs
	N.systems{s}.B = cellB;
	N.systems{s}.D = cellD;
end

for s = 1:length(N.systems)
	if (N.systems{s}.type == 1) % Continuous
		A(ind(1,s):ind(2,s),(ind(1,s):ind(2,s))) = N.systems{s}.A;
		insys = N.systems{s}.inputid;
		for t = 1:length(insys)
			if (insys(t) < 0)
				disp(sprintf('System ID: %d\n', N.systems{s}.id));
				error(['Continuous systems cannot (yet) use state as' ...
					' input']);
			end
			if (insys(t) == 0)
				% NULL input system
			else
				in = idtoindex(insys(t));
				if (N.systems{s}.impulse == 0) % Avoid ZOH inputs for impulse systems
					if (N.systems{in}.type == 1) % Continuous input
						A(ind(1,s):ind(2,s),(ind(1,in):ind(2,in))) ...
							= N.systems{s}.B{t}*N.systems{in}.C;
					else % Discrete input (use output-state)
						A(ind(1,s):ind(2,s),...
							(ind(1,in)+size(N.systems{in}.A,1):ind(2,in))) =...
							N.systems{s}.B{t};
					end
				else
					% inpulse input, do not hold the ctrl signal
					% A(ind(1,in)+size(N.systems{in}.A,1):ind(2,in),ind(1,in)+size(N.systems{in}.A,1):ind(2,in)) = -10000000;
				end
			end
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Discretize the full state matrix (continuous dynamics) as
% well as costs and noises.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Phi,R1,Qdt,Qconst] = calcc2d(A,R1,Q,N.dt);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Correct the Phi matrix to handle plant transport delays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s = 1:length(N.systems)
	if N.systems{s}.type == 1 && N.systems{s}.L > 0
		fi = Phi(ind(1,s):ind(2,s),ind(1,s):ind(2,s));
		for k=size(fi,1)+1-N.systems{s}.L*N.systems{s}.numinputs: ...
				size(fi,1)
			fi(k,k)=0;
			if k+N.systems{s}.numinputs <= size(fi,1)
				fi(k,k+N.systems{s}.numinputs) = 1;
			end
		end
		Phi(ind(1,s):ind(2,s),ind(1,s):ind(2,s)) = fi;
		insys = N.systems{s}.inputid;
		for t = 1:length(insys)
			if (insys(t) == 0)
				% NULL input system
			else
				in = idtoindex(insys(t));
				b = N.systems{s}.B{t};
				b(size(b,1)-size(b,2)+1:end,:)=eye(size(b,2),size(b,2));
				if (N.systems{in}.type == 1) % Continuous input
					Phi(ind(1,s):ind(2,s),(ind(1,in):ind(2,in))) = b*N.systems{in}.C;
				else % Discrete input (use output-state)
					Phi(ind(1,s):ind(2,s),(ind(1,in)+size(N.systems{in}.A,1): ...
						ind(2,in))) = b;
				end
			end
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5: Build the timing nodes and insert A matrices (for
% continuous evolution), E matrices (for node-entry execution) and
% noises R1 and R2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create timing nodes
for n = 1:length(N.nodes)
	% If delay dependent dynamics, how long is maximum delay?
	maxdelaydep = 1;
	for s = 1:length(N.systems)
		% If system is discrete-time and is executed at this node
		if (N.systems{s}.type == 2 && N.systems{s}.samplenode == n)
			maxdelaydep = max(maxdelaydep, size(N.systems{s}.A,3));
			maxdelaydep = max(maxdelaydep, size(N.systems{s}.C,3));
			for t=1:length(N.systems{s}.B)
				maxdelaydep = max(maxdelaydep, size(N.systems{s}.B{t},3));
			end
			for t=1:length(N.systems{s}.D)
				maxdelaydep = max(maxdelaydep, size(N.systems{s}.D{t},3));
			end
		end
	end
	% Set initial values for system matrices
	N.nodes{n}.A = Phi;
	N.nodes{n}.R1 = R1;
	N.nodes{n}.E = zeros(size(Phi,1),size(Phi,1),maxdelaydep);
	Econtinp = zeros(size(Phi,1),contoutputs,maxdelaydep);
	N.nodes{n}.R2 = zeros(size(Phi,1),size(Phi,1),maxdelaydep);
	N.nodes{n}.Q = Qdt;
	N.nodes{n}.Qconst = Qconst;

	
	for s = 1:length(N.systems)
		% Go through all continuous-time systems with impulse inputs and
		% adjust the E matrix accordingly
		if (N.systems{s}.type == 1 && N.systems{s}.impulse == 1)
			insys = N.systems{s}.inputid;
			if length(insys) > 1
				error('Cannot handle multiple inputs with impulse control (yet)')
			end
			if (insys < 0)
				error('Cannot handle state access with impulse control (yet)')
			end
			if N.systems{insys}.type ~= 2
				error('Cannot do impulse control from continuous system');
			end
			in = idtoindex(insys);
			if N.systems{insys}.samplenode == n
				l = 1;
				N.nodes{n}.E(ind(1,s):ind(2,s),ind(1,in):(ind(1,in)+size(N.systems{in}.A)-1)) = ...
					N.nodes{n}.E(ind(1,s):ind(2,s),ind(1,in):(ind(1,in)+size(N.systems{in}.A)-1)) + ...
					N.systems{s}.B{1} * N.systems{insys(t)}.C;
				% handle the direct term of the input system
				insysinsys = N.systems{insys}.inputid; % the input system to the input system
				if N.systems{insysinsys}.type == 1
					% continuous-time input to the input system
					N.nodes{n}.E(ind(1,s):ind(2,s),ind(1,insysinsys):ind(2,insysinsys),l) = ...
						N.nodes{n}.E(ind(1,s):ind(2,s),ind(1,insysinsys):ind(2,insysinsys),l) + ...
						N.systems{s}.B{1} * N.systems{insys(t)}.D{1} * N.systems{insysinsys}.C;
				else
					% discrete-time input to the input system
					N.nodes{n}.E(ind(1,s):ind(2,s),N.systems{insysinsys}.outputindex,l) = ...
						N.nodes{n}.E(ind(1,s):ind(2,s),N.systems{insysinsys}.outputindex,l) + ...
						N.systems{s}.B{1} * N.systems{insys(t)}.D{1};
				end
			end
		end
	end
		
	for s = 1:length(N.systems)
		% Go through all discrete-time systems which are updated in
		% this node and set E and R2 matrices.
		if (N.systems{s}.type == 2 && N.systems{s}.samplenode == n)
			% A discrete-time system is to be updated
			insys = N.systems{s}.inputid;
			%%%updated(ind(1,s):ind(2,s)) = 1; ???
			for l=1:maxdelaydep
				% Set E matrices
				N.nodes{n}.E(ind(1,s):ind(2,s),ind(1,s):ind(2,s),l) = ...
					N.nodes{n}.E(ind(1,s):ind(2,s),ind(1,s):ind(2,s),l) + ...
					[N.systems{s}.A(:,:,min(size(N.systems{s}.A,3),l)) ...
					zeros(size(N.systems{s}.A(:,:,min(size(N.systems{s}.A,3),l)),1),N.systems{s}.outputs);...
					N.systems{s}.C(:,:,min(size(N.systems{s}.C,3),l)) ...
					zeros(N.systems{s}.outputs)];
			end
			% Set R2
			N.nodes{n}.R2(ind(1,s):ind(2,s),ind(1,s):ind(2,s),l) = ...
				N.nodes{n}.R2(ind(1,s):ind(2,s),ind(1,s):ind(2,s),l)+ ...
				N.systems{s}.R2;
			
			% Now, go through all inputs to the system and alter the
			% E matrices accordingly, and add R2 noise if the input
			% system has output noise.
			for t = 1:length(insys)
				if (insys(t) ~= 0)
					if (insys(t) < 0) % Negative input index means that we
						% access the state directly instead of output
						in = idtoindex(-insys(t));
						statedirect=1;
					else
						in = idtoindex(insys(t));
						statedirect=0;
					end
					for l=1:maxdelaydep
						% If the discrete system is dependent on time, make E 3-D
						% This is the cause of all "min(size(N.systems..."
						% indices, as not all matrices must be 3-D because one is
						if (N.systems{in}.type == 1) % Continuous-time input system
							if (statedirect)
								N.nodes{n}.E(ind(1,s):ind(2,s),(ind(1,in):ind(2,in)),l) ...
									=N.nodes{n}.E(ind(1,s):ind(2,s),(ind(1,in):ind(2,in)),l) ...
									+[N.systems{s}.B{t}(:,:,min(size(N.systems{s}.B{t},3),l));...
									N.systems{s}.D{t}(:,:,min(size(N.systems{s}.D{t},3),l))];
							else
								N.nodes{n}.E(ind(1,s):ind(2,s),(ind(1,in):ind(2,in)),l) ...
									= N.nodes{n}.E(ind(1,s):ind(2,s),(ind(1,in):ind(2,in)),l) ...
									+[N.systems{s}.B{t}(:,:,min(size(N.systems{s}.B{t},3),l))*...
									N.systems{in}.C(:,:,min(size(N.systems{in}.C,3),l));...
									N.systems{s}.D{t}(:,:,min(size(N.systems{s}.D{t},3),l))*...
									N.systems{in}.C(:,:,min(size(N.systems{in}.C,3),l))];
								% Let the continuous system's output noise be added
								% as sample noise
								BD = [N.systems{s}.B{t}(:,:,min(size(N.systems{s}.B{t},3),l));...
									N.systems{s}.D{t}(:,:,min(size(N.systems{s}.D{t},3),l))];
								Econtinp(ind(1,s):ind(2,s),indcontout(1,in):indcontout(2,in),l) = ...
									Econtinp(ind(1,s):ind(2,s),indcontout(1,in):indcontout(2,in),l)+BD;
							end
						else % Discrete-time input system (use output-state)
							if (statedirect)
								N.nodes{n}.E(ind(1,s):ind(2,s),(ind(1,in):ind(1,in)+size(N.systems{in}.A(:,:,min(size(N.systems{s}.A,3),l)),1)-1),l)= ...
									N.nodes{n}.E(ind(1,s):ind(2,s),(ind(1,in):ind(1,in)+size(N.systems{in}.A(:,:,min(size(N.systems{s}.A,3),l)),1)-1),l)+ ...
									[N.systems{s}.B{t}(:,:,min(size(N.systems{s}.B{t},3),l));N.systems{s}.D{t}(:,:,min(size(N.systems{s}.D{t},3),l))];
							else
								N.nodes{n}.E(ind(1,s):ind(2,s),(ind(1,in)+size(N.systems{in}.A(:,:,min(size(N.systems{s}.A,3),l)),1):ind(2,in)),l) = ...
									N.nodes{n}.E(ind(1,s):ind(2,s),(ind(1,in)+size(N.systems{in}.A(:,:,min(size(N.systems{s}.A,3),l)),1):ind(2,in)),l) + ...
									[N.systems{s}.B{t}(:,:,min(size(N.systems{s}.B{t},3),l));N.systems{s}.D{t}(:,:,min(size(N.systems{s}.D{t},3),l))];
							end
						end
					end
				end
			end
		else
			% This system is not discrete-time, or will not be executed
			% at this exec node. Since one discrete-time system can be
			% executed at several timing nodes (adddiscexec()), it is
			% still possible that the corresponding states should be
			% updated.
			% If the system is really not updated, set E to I.
			noexec = 1;
			for t = 1:length(N.systems)
				if (N.systems{s}.id == N.systems{t}.id && ...
						N.systems{t}.type == 2 && N.systems{t}.samplenode == n)
					% This system WILL be executed this node
					noexec = 0;
				end
			end
			if (noexec && ~N.systems{s}.sysoption)
				% This system is not at all updated at this timing node,
				% so set E to I.
				for l=1:maxdelaydep
					N.nodes{n}.E(ind(1,s):ind(2,s),ind(1,s):ind(2,s),l) = ...
						N.nodes{n}.E(ind(1,s):ind(2,s),ind(1,s):ind(2,s),l) + ...
						eye(N.systems{s}.states);
				end
			end
		end
	end
	R2 = zeros(contoutputs);
	% Add output noise for continuous outputs
	for s = 1:length(N.systems)
		if (N.systems{s}.type == 1)
			R2(indcontout(1,s):indcontout(2,s),indcontout(1,s):indcontout(2,s))=...
				N.systems{s}.R2;
		end
	end
	for l=1:maxdelaydep
		N.nodes{n}.R2(:,:,l) = N.nodes{n}.R2(:,:,l) + Econtinp(:,:,l)*R2*Econtinp(:,:,l)';
	end
end
