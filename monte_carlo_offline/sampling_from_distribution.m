function [ri] = sampling_from_distribution(BCRT, WCRT)

% uniform distribution
%ri = BCRT + (WCRT - BCRT) .* rand(1);

% normal distribution
ri = normrnd((WCRT - BCRT) / 2, (WCRT - BCRT) / 3.5);

if ri < BCRT
    ri = BCRT;
elseif ri > WCRT
    ri = WCRT;
end

end
