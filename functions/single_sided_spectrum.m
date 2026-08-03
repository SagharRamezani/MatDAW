function [f, magnitude] = single_sided_spectrum(x, fs)
%SINGLE_SIDED_SPECTRUM Compute the normalized single-sided FFT magnitude.

validateattributes(x, {'numeric'}, {'vector', 'real', 'finite'});
validateattributes(fs, {'numeric'}, {'scalar', 'real', 'positive', 'finite'});

x = x(:);
N = numel(x);

X = fft(x);
twoSided = abs(X / N);

magnitude = twoSided(1:floor(N / 2) + 1);

if numel(magnitude) > 2
    magnitude(2:end-1) = 2 * magnitude(2:end-1);
end

f = fs * (0:floor(N / 2)).' / N;
end
