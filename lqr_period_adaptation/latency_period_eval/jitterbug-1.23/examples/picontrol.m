% Jitterbug example: picontrol.m
% ==============================
% LQ-optimal PI control of an integrator
%
% The process is  dot x = w
%                 dot w = u + v
% where v is white noise with intensity 1.
%
% The goal of the control is to minimize the cost function
%                 J = E{x^2 + ((Delta u)/h)^2}
%
% The optimal continuous-time controller is the PI controller
%                 u = -sqrt(2)(y + integral(y))

% Define extended plant model
A = [0 1; 0 0];
B = [0; 1];
C = [1 0];

Qc = diag([1 0 1]);

R1c = diag([0 1]); % state noise  
R2 = 0;            % meas. noise

sys = ss(A,B,C,0);

fvec = logspace(-1,2);

impflag = 1; % impulse control flag

% Optimal continuous-time controller
K = sqrt(2);
Ti = 1;
s = tf('s');
z = tf('z');
ctrl_cont = -K*(1+1/(Ti*s));

col = {'b','r','g'};

hold off
loglog([1e-1 1e2],[sqrt(2) sqrt(2)],'k--')
hold on

for mode = 1:3
	Jvec = [];
	
	for f = fvec
		h = 1/f;
		
		switch mode
			case 1
				% Optimal control
				ctrl = minreal(lqgdesign(sys,Qc,R1c,R2,h,0,[],impflag),[],0);
			case 2
				% Discretization using first-order hold
			  ctrl = minreal(c2d(ctrl_cont,h,'foh')*(z-1)/z);
			case 3
			  % Discretization using backward differences
			  sp = (z-1)/(z*h);
				ctrl = minreal(-K*(1+1/(Ti*sp))*(z-1)/z);
		end
				
		Ptau = [1];
		
		N = initjitterbug(h,h);               % Initialize Jitterbug
		N = addtimingnode(N,1);               % Add node 1 (the periodic node)
		N = addcontsys(N,1,sys,2,Qc,R1c,R2,impflag);
		N = adddiscsys(N,2,ctrl,1,1);         % Controller
		N = calcdynamics(N);                  % Calculate the internal dynamics
		J = calccost(N)                       % Calculate the cost
		
		if (J > 1e10)
			J = 1e10;
		end
		
		Jvec = [Jvec J];

	end
	
	loglog(fvec,Jvec,col{mode})
	
end

axis([1e-1 1e2 1e0 1e2])
legend('Continuous','Optimal','FOH','Backward')
xlabel('Sampling frequency')
ylabel('Cost')

hold off

