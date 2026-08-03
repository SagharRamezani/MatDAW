function y = match_signal_length(x, targetLength)
%MATCH_SIGNAL_LENGTH Repeat or crop a signal to a required length.

validateattributes(x, {'numeric'}, {'vector', 'real', 'finite', 'nonempty'});
validateattributes(targetLength, {'numeric'}, ...
    {'scalar', 'integer', 'positive', 'finite'});

x = x(:);

if numel(x) >= targetLength
    y = x(1:targetLength);
    return;
end

repeatCount = ceil(targetLength / numel(x));
y = repmat(x, repeatCount, 1);
y = y(1:targetLength);
end
