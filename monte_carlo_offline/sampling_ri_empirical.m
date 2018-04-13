function [ri] = sampling_ri_empirical(p_ri)

ri = emprand(p_ri);

ri = ri * 10^-5;

end
