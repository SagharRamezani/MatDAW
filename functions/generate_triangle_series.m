function x = generate_triangle_series(t, f0, amplitude, harmonics)
%GENERATE_TRIANGLE_SERIES Generate an odd triangle wave by Fourier series.
%
% x(t) = (8A/pi^2) * sum_k [sin(k*pi/2)/k^2] sin(2*pi*k*f0*t)

validateattributes(t, {'numeric'}, {'vector', 'real', 'finite'});
validateattributes(f0, {'numeric'}, {'scalar', 'real', 'positive', 'finite'});
validateattributes(amplitude, {'numeric'}, {'scalar', 'real', 'nonnegative', 'finite'});
validateattributes(harmonics, {'numeric'}, {'vector', 'integer', 'positive'});

t = t(:);
x = zeros(size(t));

for k = harmonics(:).'
    coefficient = (8 * amplitude / pi^2) * sin(k * pi / 2) / (k^2);
    x = x + coefficient * sin(2 * pi * k * f0 * t);
end
end
