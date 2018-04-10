% sampling response time with normal distribution
function [ri] = sampling_ri_norm(BCRT, WCRT)

% normal distribution
ri = normrnd((WCRT - BCRT) / 2, (WCRT - BCRT) / 3.5);

if ri < BCRT
    ri = BCRT;
elseif ri > WCRT
    ri = WCRT;
end

end
