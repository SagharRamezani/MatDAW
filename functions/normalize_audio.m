function y = normalize_audio(x, peakLimit)
%NORMALIZE_AUDIO Prevent clipping while preserving level when possible.

if nargin < 2
    peakLimit = 0.99;
end

validateattributes(x, {'numeric'}, {'real', 'finite'});
validateattributes(peakLimit, {'numeric'}, ...
    {'scalar', 'real', 'positive', '<=', 1});

peakValue = max(abs(x(:)));

if peakValue > peakLimit
    y = x * (peakLimit / peakValue);
else
    y = x;
end
end
