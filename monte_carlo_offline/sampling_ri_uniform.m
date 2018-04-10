% sampling response time with uniform distribution
function [ri] = sampling_ri_uniform(BCRT, WCRT)

% uniform distribution
ri = BCRT + (WCRT - BCRT) .* rand(1);

if ri < BCRT
    ri = BCRT;
elseif ri > WCRT
    ri = WCRT;
end

end
