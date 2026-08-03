function results = phase1_synthesizer(cfg)
%PHASE1_SYNTHESIZER Generate and analyze triangle-wave approximations.

fprintf('--- Phase 1: Triangle-wave synthesis ---\n');

fs = cfg.phase1.fs;
f0 = cfg.phase1.f0;
duration = cfg.phase1.duration;
A = cfg.phase1.amplitude;

nyquistFrequency = fs / 2;
highestRequestedFrequency = max(cfg.phase1.harmonicsC) * f0;

if highestRequestedFrequency >= nyquistFrequency
    error(['Phase 1 harmonic selection reaches or exceeds Nyquist. ' ...
        'Reduce the maximum harmonic or increase fs.']);
end

t = (0:1/fs:duration - 1/fs).';

xA = generate_triangle_series(t, f0, A, cfg.phase1.harmonicsA);
xB = generate_triangle_series(t, f0, A, cfg.phase1.harmonicsB);
xC = generate_triangle_series(t, f0, A, cfg.phase1.harmonicsC);

xAWrite = normalize_audio(xA);
xBWrite = normalize_audio(xB);
xCWrite = normalize_audio(xC);

fileA = fullfile(cfg.paths.phase1Audio, 'x_a.wav');
fileB = fullfile(cfg.paths.phase1Audio, 'x_b.wav');
fileC = fullfile(cfg.paths.phase1Audio, 'x_c.wav');

audiowrite(fileA, xAWrite, fs);
audiowrite(fileB, xBWrite, fs);
audiowrite(fileC, xCWrite, fs);

fprintf('Created: %s\n', fileA);
fprintf('Created: %s\n', fileB);
fprintf('Created: %s\n', fileC);

% Time-domain comparison
displayDuration = cfg.phase1.displayPeriods / f0;
displayIndices = t <= displayDuration;

figTime = figure('Name', 'Phase 1 - Time Domain', 'Color', 'w');

subplot(3, 1, 1);
plot(t(displayIndices), xA(displayIndices), 'LineWidth', 1.1);
grid on;
title('State A: Fundamental Only');
xlabel('Time (s)');
ylabel('Amplitude');
ylim([-1.1 1.1]);

subplot(3, 1, 2);
plot(t(displayIndices), xB(displayIndices), 'LineWidth', 1.1);
grid on;
title('State B: Five Odd Harmonics');
xlabel('Time (s)');
ylabel('Amplitude');
ylim([-1.1 1.1]);

subplot(3, 1, 3);
plot(t(displayIndices), xC(displayIndices), 'LineWidth', 1.1);
grid on;
title('State C: Harmonics k = 1,...,50');
xlabel('Time (s)');
ylabel('Amplitude');
ylim([-1.1 1.1]);

timeFigurePath = fullfile( ...
    cfg.paths.phase1Figures, 'phase1_time_domain.png');

drawnow;
exportgraphics(figTime, timeFigurePath, 'Resolution', 300);

% Frequency-domain analysis of State C
[f, magnitude] = single_sided_spectrum(xC, fs);

figFFT = figure('Name', 'Phase 1 - Spectrum', 'Color', 'w');
plot(f, magnitude, 'LineWidth', 1.0);
grid on;
title('Single-Sided Spectrum of State C');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
xlim([0 nyquistFrequency]);

fftFigurePath = fullfile( ...
    cfg.paths.phase1Figures, 'phase1_state_c_fft.png');

drawnow;
exportgraphics(figFFT, fftFigurePath, 'Resolution', 300);

% Store theoretical nonzero harmonic information.
oddHarmonics = cfg.phase1.harmonicsC( ...
    mod(cfg.phase1.harmonicsC, 2) == 1);

harmonicFrequencies = oddHarmonics(:) * f0;
theoreticalCoefficients = ...
    (8 * A / pi^2) .* sin(oddHarmonics(:) * pi / 2) ...
    ./ (oddHarmonics(:).^2);

harmonicTable = table( ...
    oddHarmonics(:), ...
    harmonicFrequencies, ...
    theoreticalCoefficients, ...
    abs(theoreticalCoefficients), ...
    'VariableNames', { ...
        'HarmonicIndex', ...
        'FrequencyHz', ...
        'Coefficient', ...
        'CoefficientMagnitude'});

harmonicTablePath = fullfile( ...
    cfg.paths.results, 'phase1_harmonics.csv');
writetable(harmonicTable, harmonicTablePath);

results.fs = fs;
results.f0 = f0;
results.t = t;
results.xA = xA;
results.xB = xB;
results.xC = xC;
results.harmonicTable = harmonicTable;
results.audioFiles = {fileA, fileB, fileC};
results.figureFiles = {timeFigurePath, fftFigurePath};

save(fullfile(cfg.paths.results, 'phase1_results.mat'), 'results');

fprintf('Created: %s\n', timeFigurePath);
fprintf('Created: %s\n', fftFigurePath);
fprintf('Created: %s\n', harmonicTablePath);

if cfg.phase1.playAudio
    fprintf('Playing State A...\n');
    sound(xAWrite, fs);
    pause(duration + 0.5);

    fprintf('Playing State B...\n');
    sound(xBWrite, fs);
    pause(duration + 0.5);

    fprintf('Playing State C...\n');
    sound(xCWrite, fs);
end

fprintf('Phase 1 script finished successfully.\n');
end
