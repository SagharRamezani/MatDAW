function results = phase4_equalizer(cfg)
%PHASE4_EQUALIZER Three-band parallel Butterworth equalizer.
%
% Input:
%   audio/phase3/y_fir_stable.wav
%
% Bands:
%   Low-pass: 0 to 300 Hz
%   Band-pass: 300 to 2000 Hz
%   High-pass: above 2000 Hz
%
% Presets:
%   Bass Boost = 2.5*Low + 1.0*Mid + 0.5*High
%   Muffled    = 2.0*Low + 0.1*Mid + 0.1*High

fprintf('--- Phase 4: Three-band Butterworth equalizer ---\n');

inputFile = fullfile(cfg.paths.phase3Audio, 'y_fir_stable.wav');

if ~exist(inputFile, 'file')
    error('Required Phase 3 FIR output not found: %s', inputFile);
end

[x, fs] = audioread(inputFile);

if size(x, 2) > 1
    x = mean(x, 2);
end

x = x(:);
x = x - mean(x);
x = normalize_audio(x, 0.95);

nyquist = fs / 2;
lowCutoff = cfg.phase4.lowCutoffHz;
highCutoff = cfg.phase4.highCutoffHz;

if highCutoff >= nyquist
    error('High cutoff must be below Nyquist frequency.');
end

% Normalized digital cutoff frequencies
wLow = lowCutoff / nyquist;
wHigh = highCutoff / nyquist;

% Three Butterworth IIR filters.
[bLow, aLow] = butter( ...
    cfg.phase4.lowpassOrder, wLow, 'low');

% For a band-pass design, butter(n,[w1 w2],'bandpass') creates an
% overall transfer function of order 2n. Therefore n = 2 gives an
% overall fourth-order band-pass filter.
[bBand, aBand] = butter( ...
    cfg.phase4.bandpassPrototypeOrder, ...
    [wLow wHigh], ...
    'bandpass');

[bHigh, aHigh] = butter( ...
    cfg.phase4.highpassOrder, wHigh, 'high');

% Pole-based stability verification.
pLow = roots(aLow);
pBand = roots(aBand);
pHigh = roots(aHigh);

stableLow = all(abs(pLow) < 1);
stableBand = all(abs(pBand) < 1);
stableHigh = all(abs(pHigh) < 1);

if ~(stableLow && stableBand && stableHigh)
    error('At least one Phase 4 filter is unstable.');
end

% Parallel three-band decomposition.
xLow = filter(bLow, aLow, x);
xBand = filter(bBand, aBand, x);
xHigh = filter(bHigh, aHigh, x);

gBass = cfg.phase4.bassBoostGains;
gMuffled = cfg.phase4.muffledGains;

yBassRaw = ...
    gBass(1) * xLow + ...
    gBass(2) * xBand + ...
    gBass(3) * xHigh;

yMuffledRaw = ...
    gMuffled(1) * xLow + ...
    gMuffled(2) * xBand + ...
    gMuffled(3) * xHigh;

yBass = normalize_audio(yBassRaw, 0.95);
yMuffled = normalize_audio(yMuffledRaw, 0.95);

bassFile = fullfile(cfg.paths.phase4Audio, 'y_bass_boost.wav');
muffledFile = fullfile(cfg.paths.phase4Audio, 'y_muffled.wav');

audiowrite(bassFile, yBass, fs);
audiowrite(muffledFile, yMuffled, fs);

fprintf('Created: %s\n', bassFile);
fprintf('Created: %s\n', muffledFile);

%% Frequency responses of the three filters
nFreq = 4096;

[HLow, f] = freqz(bLow, aLow, nFreq, fs);
[HBand, ~] = freqz(bBand, aBand, nFreq, fs);
[HHigh, ~] = freqz(bHigh, aHigh, nFreq, fs);

figResponses = figure( ...
    'Name', 'Phase 4 - Filter Responses', ...
    'Color', 'w');

plot(f, 20*log10(abs(HLow) + eps), 'LineWidth', 1.1);
hold on;
plot(f, 20*log10(abs(HBand) + eps), 'LineWidth', 1.1);
plot(f, 20*log10(abs(HHigh) + eps), 'LineWidth', 1.1);
hold off;

grid on;
title('Magnitude Responses of the Three Butterworth Filters');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
legend('Low-pass', 'Band-pass', 'High-pass', 'Location', 'best');
xlim([0 min(5000, nyquist)]);
ylim([-100 5]);

responseFigurePath = fullfile( ...
    cfg.paths.phase4Figures, ...
    'phase4_filter_frequency_responses.png');

drawnow;
exportgraphics(figResponses, responseFigurePath, 'Resolution', 300);

%% Combined spectra of input and both presets
[fInput, magInput] = single_sided_spectrum(x, fs);
[fBass, magBass] = single_sided_spectrum(yBass, fs);
[fMuffled, magMuffled] = single_sided_spectrum(yMuffled, fs);

figSpectra = figure( ...
    'Name', 'Phase 4 - Output Spectra', ...
    'Color', 'w');

subplot(3, 1, 1);
plot(fInput, magInput, 'LineWidth', 0.9);
grid on;
title('Input FIR Echo Spectrum');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
xlim([0 min(5000, nyquist)]);

subplot(3, 1, 2);
plot(fBass, magBass, 'LineWidth', 0.9);
grid on;
title('Bass Boost Output Spectrum');
xlabel('Frequency (Hz)');
ylabel('|Y_{bass}(f)|');
xlim([0 min(5000, nyquist)]);

subplot(3, 1, 3);
plot(fMuffled, magMuffled, 'LineWidth', 0.9);
grid on;
title('Muffled Output Spectrum');
xlabel('Frequency (Hz)');
ylabel('|Y_{muffled}(f)|');
xlim([0 min(5000, nyquist)]);

spectraFigurePath = fullfile( ...
    cfg.paths.phase4Figures, ...
    'phase4_output_spectra.png');

drawnow;
exportgraphics(figSpectra, spectraFigurePath, 'Resolution', 300);

%% Impulse responses
impulseLength = cfg.phase4.impulseLength;

[hLow, nLow] = impz(bLow, aLow, impulseLength);
[hBand, nBand] = impz(bBand, aBand, impulseLength);
[hHigh, nHigh] = impz(bHigh, aHigh, impulseLength);

figImpulse = figure( ...
    'Name', 'Phase 4 - Impulse Responses', ...
    'Color', 'w');

subplot(3, 1, 1);
stem(nLow, hLow, 'filled', 'MarkerSize', 2);
grid on;
title('Low-pass Impulse Response');
xlabel('n');
ylabel('h_{LP}[n]');

subplot(3, 1, 2);
stem(nBand, hBand, 'filled', 'MarkerSize', 2);
grid on;
title('Band-pass Impulse Response');
xlabel('n');
ylabel('h_{BP}[n]');

subplot(3, 1, 3);
stem(nHigh, hHigh, 'filled', 'MarkerSize', 2);
grid on;
title('High-pass Impulse Response');
xlabel('n');
ylabel('h_{HP}[n]');

impulseFigurePath = fullfile( ...
    cfg.paths.phase4Figures, ...
    'phase4_impulse_responses.png');

drawnow;
exportgraphics(figImpulse, impulseFigurePath, 'Resolution', 300);

%% Pole-zero diagrams
figZPlane = figure( ...
    'Name', 'Phase 4 - Pole-Zero Diagrams', ...
    'Color', 'w');

subplot(1, 3, 1);
zplane(bLow, aLow);
title('Low-pass Pole-Zero Plot');

subplot(1, 3, 2);
zplane(bBand, aBand);
title('Band-pass Pole-Zero Plot');

subplot(1, 3, 3);
zplane(bHigh, aHigh);
title('High-pass Pole-Zero Plot');

zplaneFigurePath = fullfile( ...
    cfg.paths.phase4Figures, ...
    'phase4_pole_zero_plots.png');

drawnow;
exportgraphics(figZPlane, zplaneFigurePath, 'Resolution', 300);

%% Save coefficient and stability summaries
filterSummary = table( ...
    ["LowPass"; "BandPass"; "HighPass"], ...
    [numel(aLow)-1; numel(aBand)-1; numel(aHigh)-1], ...
    [max(abs(pLow)); max(abs(pBand)); max(abs(pHigh))], ...
    [stableLow; stableBand; stableHigh], ...
    'VariableNames', { ...
        'Filter', ...
        'OverallOrder', ...
        'MaximumPoleMagnitude', ...
        'Stable'});

summaryPath = fullfile( ...
    cfg.paths.results, ...
    'phase4_filter_summary.csv');

writetable(filterSummary, summaryPath);

results.fs = fs;
results.inputFile = inputFile;

results.lowpass.b = bLow;
results.lowpass.a = aLow;
results.lowpass.poles = pLow;
results.lowpass.stable = stableLow;

results.bandpass.b = bBand;
results.bandpass.a = aBand;
results.bandpass.poles = pBand;
results.bandpass.stable = stableBand;

results.highpass.b = bHigh;
results.highpass.a = aHigh;
results.highpass.poles = pHigh;
results.highpass.stable = stableHigh;

results.bassBoostGains = gBass;
results.muffledGains = gMuffled;

results.audioFiles = {bassFile, muffledFile};
results.figureFiles = { ...
    responseFigurePath, ...
    spectraFigurePath, ...
    impulseFigurePath, ...
    zplaneFigurePath};

save(fullfile(cfg.paths.results, 'phase4_results.mat'), 'results');

fprintf('Created: %s\n', responseFigurePath);
fprintf('Created: %s\n', spectraFigurePath);
fprintf('Created: %s\n', impulseFigurePath);
fprintf('Created: %s\n', zplaneFigurePath);
fprintf('Created: %s\n', summaryPath);

fprintf('\nStability verification:\n');
fprintf('Low-pass  max |pole| = %.6f -> stable\n', max(abs(pLow)));
fprintf('Band-pass max |pole| = %.6f -> stable\n', max(abs(pBand)));
fprintf('High-pass max |pole| = %.6f -> stable\n', max(abs(pHigh)));

if cfg.phase4.playAudio
    fprintf('Playing Bass Boost output...\n');
    sound(yBass, fs);
    pause(numel(yBass) / fs + 0.5);

    fprintf('Playing Muffled output...\n');
    sound(yMuffled, fs);
end

fprintf('Phase 4 script finished successfully.\n');
end
