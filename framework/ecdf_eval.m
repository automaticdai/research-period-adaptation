% ecdf_eval.m
% evaluate the value of a ecdf function @ x <= x_b
% intput: @f: function value of ecdf, @x: x value of ecdf, @x_u: upper
%         limit of x
% output: evaluated value
function [val] = ecdf_eval(f, x, x_u)
val = 1000;

x_max = max(x);
x_min = min(x);

if (x_u >= x_max)
    val = 1;
    return
elseif (x_u <= x_min)
    val = 0;
    return
else
    for i = 1:numel(x) 
        if x_u < x(i)
            val = f(i);
            return
        end
     end
end

end