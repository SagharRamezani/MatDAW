function [f, magnitude] = centered_spectrum(x, fs)
%CENTERED_SPECTRUM Compute a normalized, centered FFT magnitude.

validateattributes(x, {'numeric'}, {'vector', 'real', 'finite'});
validateattributes(fs, {'numeric'}, {'scalar', 'real', 'positive', 'finite'});

x = x(:);
N = numel(x);

X = fftshift(fft(x));
magnitude = abs(X) / N;

if mod(N, 2) == 0
    f = (-N/2:N/2-1).' * (fs / N);
else
    f = (-(N-1)/2:(N-1)/2).' * (fs / N);
end
end
