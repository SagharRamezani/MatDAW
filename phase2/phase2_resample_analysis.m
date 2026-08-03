function results = phase2_resample_analysis(cfg)
%PHASE2_RESAMPLE_ANALYSIS Compare naive and anti-aliased rate conversion.

fprintf('--- Phase 2: Sampling and anti-aliasing ---\n');

fs1 = cfg.phase2.fsOriginal;
fs2 = cfg.phase2.fsReduced;
cutoffHz = cfg.phase2.cutoffHz;
filterOrder = cfg.phase2.filterOrder;

originalFile = fullfile(cfg.paths.phase2Audio, 'x_original.wav');

if ~exist(originalFile, 'file')
    error(['Required recording not found: ' originalFile newline ...
        'First run: phase2_record_audio(config())']);
end

[xOriginal, fileFs] = audioread(originalFile);

if fileFs ~= fs1
    error('x_original.wav must have a sample rate of %d Hz.', fs1);
end

if size(xOriginal, 2) > 1
    xOriginal = mean(xOriginal, 2);
end

xOriginal = xOriginal - mean(xOriginal);
xOriginal = normalize_audio(xOriginal, 0.95);

% Common target-time grid for direct sample-rate conversion.
durationAvailable = (numel(xOriginal) - 1) / fs1;
tOriginal = (0:numel(xOriginal)-1).' / fs1;
tReduced = (0:1/fs2:durationAvailable).';

% Scenario A: direct conversion without an anti-aliasing filter.
% Interpolation changes the sample grid but does not remove frequencies
% above the new Nyquist frequency of 4000 Hz.
xNaive = interp1(tOriginal, xOriginal, tReduced, 'linear');

% Scenario B: low-pass anti-aliasing filter, then the same conversion.
normalizedCutoff = cutoffHz / (fs1 / 2);
[b, a] = butter(filterOrder, normalizedCutoff, 'low');
xFiltered = filtfilt(b, a, xOriginal);
xAntialiased = interp1(tOriginal, xFiltered, tReduced, 'linear');

xNaive = normalize_audio(xNaive, 0.95);
xAntialiased = normalize_audio(xAntialiased, 0.95);

naiveFile = fullfile(cfg.paths.phase2Audio, 'x_naive.wav');
antialiasedFile = fullfile(cfg.paths.phase2Audio, 'x_antialiased.wav');

audiowrite(originalFile, xOriginal, fs1);
audiowrite(naiveFile, xNaive, fs2);
audiowrite(antialiasedFile, xAntialiased, fs2);

fprintf('Created: %s\n', originalFile);
fprintf('Created: %s\n', naiveFile);
fprintf('Created: %s\n', antialiasedFile);

% Centered spectra
[fOriginal, magOriginal] = centered_spectrum(xOriginal, fs1);
[fNaive, magNaive] = centered_spectrum(xNaive, fs2);
[fAntialiased, magAntialiased] = centered_spectrum(xAntialiased, fs2);

figSpectrum = figure( ...
    'Name', 'Phase 2 - Spectrum Comparison', ...
    'Color', 'w');

subplot(3, 1, 1);
plot(fOriginal, magOriginal, 'LineWidth', 0.9);
grid on;
title('Original Voice Spectrum, f_s = 44100 Hz');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
xlim([-8000 8000]);

subplot(3, 1, 2);
plot(fNaive, magNaive, 'LineWidth', 0.9);
grid on;
title('Naive Rate Conversion, f_s = 8000 Hz');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
xlim([-4000 4000]);

subplot(3, 1, 3);
plot(fAntialiased, magAntialiased, 'LineWidth', 0.9);
grid on;
title('Anti-Aliased Rate Conversion, f_s = 8000 Hz');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
xlim([-4000 4000]);

spectrumFigurePath = fullfile( ...
    cfg.paths.phase2Figures, 'phase2_spectrum_comparison.png');

drawnow;
exportgraphics(figSpectrum, spectrumFigurePath, 'Resolution', 300);

% Anti-aliasing filter response
[H, fFilter] = freqz(b, a, 4096, fs1);

figFilter = figure( ...
    'Name', 'Phase 2 - Anti-Aliasing Filter', ...
    'Color', 'w');

plot(fFilter, 20 * log10(abs(H) + eps), 'LineWidth', 1.1);
grid on;
title(sprintf( ...
    'Butterworth Anti-Aliasing Filter, Order %d, Cutoff %d Hz', ...
    filterOrder, cutoffHz));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 8000]);
ylim([-100 5]);

filterFigurePath = fullfile( ...
    cfg.paths.phase2Figures, 'phase2_antialias_filter_response.png');

drawnow;
exportgraphics(figFilter, filterFigurePath, 'Resolution', 300);

% Save numerical results.
results.fsOriginal = fs1;
results.fsReduced = fs2;
results.cutoffHz = cutoffHz;
results.filterOrder = filterOrder;
results.filterNumerator = b;
results.filterDenominator = a;
results.originalFile = originalFile;
results.naiveFile = naiveFile;
results.antialiasedFile = antialiasedFile;
results.figureFiles = {spectrumFigurePath, filterFigurePath};

save(fullfile(cfg.paths.results, 'phase2_results.mat'), 'results');

summaryTable = table( ...
    ["Original"; "Naive"; "AntiAliased"], ...
    [fs1; fs2; fs2], ...
    [numel(xOriginal); numel(xNaive); numel(xAntialiased)], ...
    [max(abs(xOriginal)); max(abs(xNaive)); max(abs(xAntialiased))], ...
    'VariableNames', {'Signal', 'SampleRateHz', 'NumberOfSamples', 'Peak'});

summaryPath = fullfile(cfg.paths.results, 'phase2_summary.csv');
writetable(summaryTable, summaryPath);

fprintf('Created: %s\n', spectrumFigurePath);
fprintf('Created: %s\n', filterFigurePath);
fprintf('Created: %s\n', summaryPath);

if cfg.phase2.playAudio
    fprintf('Playing original recording...\n');
    sound(xOriginal, fs1);
    pause(numel(xOriginal) / fs1 + 0.5);

    fprintf('Playing naive output...\n');
    sound(xNaive, fs2);
    pause(numel(xNaive) / fs2 + 0.5);

    fprintf('Playing anti-aliased output...\n');
    sound(xAntialiased, fs2);
end

fprintf('Phase 2 script finished successfully.\n');
end
