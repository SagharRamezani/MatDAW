function y = recursive_echo(x, delaySamples, alpha)
%RECURSIVE_ECHO Implement y[n] = x[n] + alpha*y[n-R].
%
% The direct recursion avoids constructing a very high-order denominator
% polynomial for a long audio delay.

validateattributes(x, {'numeric'}, {'vector', 'real', 'finite'});
validateattributes(delaySamples, {'numeric'}, ...
    {'scalar', 'integer', 'positive', 'finite'});
validateattributes(alpha, {'numeric'}, {'scalar', 'real', 'finite'});

x = x(:);
y = zeros(size(x));

for n = 1:numel(x)
    if n > delaySamples
        y(n) = x(n) + alpha * y(n - delaySamples);
    else
        y(n) = x(n);
    end
end
end
