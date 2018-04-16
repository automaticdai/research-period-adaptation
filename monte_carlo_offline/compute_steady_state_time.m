function [ Ts, Ts_idx ] = compute_steady_state_time(y, t, ref, tolerance_prec)
% [Inputs] 
% y: system response
% t: time sequence
% ref: reference, 
% tolerance_prec: percentage of tolerance in the steady-state
%
% [Outputs]
% Ts: steady-state time, NaN if not existed

ref_lower = ref - tolerance_prec;
ref_upper = ref + tolerance_prec;

idx = ((y > ref_lower) & (y < ref_upper));
Ts_idx = find(~idx, 1, 'last') + 1;

if (isempty(Ts_idx))
    Ts = 0;
elseif (Ts_idx > numel(y))
    Ts = NaN;
else
    Ts = t(Ts_idx) - t(1);
end
