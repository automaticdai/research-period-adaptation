function [Phi,R,Q,Qconst] = calcc2d(a,r1,q,dt) 
% [Phi,R,Q,Qconst] = calcc2d(a,r,q,h) 
%
% Calculate the discrete-time (ZOH) version of the continuous
% system 
%                 xdot = a*x + w
% where the incremental variance of w is r. The cost of the system
% is 
%                 J = integral_0^h (x'*q*x) dt
% The resulting discrete-time system is
%                 x(n+1) = Phi*x(n) + e(n)
% where the variance of e(n) is R, and the cost is
%                 J = x'*Q*x + Qconst.

n = size(a,1); 
Za = zeros(n);
M = [ -a' q 
      Za  a ];

if (max(abs(eig(M*dt))) > 4)
  % Too fast poles, half sampling interval and try again (for
  % numerical reasons)
  [Phi,R,Q,Qconst] = calcc2d(a,r1,q,dt/2);
  % Then rebuild the correct matrices
  Qconst = 2*Qconst+trace(Q*R);
  Q = Q+Phi'*Q*Phi;
  R = R+Phi*R*Phi';
  Phi = Phi*Phi;
  return;
end

phi = expm(M*dt);
phi12 = phi(1:n,n+1:2*n);
phi22 = phi(n+1:2*n,n+1:2*n);
Q = phi22'*phi12;
Q = (Q+Q')/2;
Phi = phi22(1:n,1:n);

M = [ -a eye(n) Za
      Za -a r1' 
      Za Za  a' ];
phi = expm(M*dt);
phi13 = phi(1:n,2*n+1:3*n);
phi23 = phi(n+1:2*n,2*n+1:3*n);
phi33 = phi(2*n+1:3*n,2*n+1:3*n);
R = phi33'*phi23;
R = (R+R')/2; 
Qnoise = phi33'*phi13;
Qconst = trace(Qnoise*q);

