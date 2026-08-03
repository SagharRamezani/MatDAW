function results = phase3_echo_processing(cfg)
%PHASE3_ECHO_PROCESSING Mix voice and music, then apply FIR/IIR echoes.

fprintf('--- Phase 3: Studio mix and echo systems ---\n');

musicFile = fullfile(cfg.paths.phase1Audio, 'x_c.wav');
voiceFile = fullfile(cfg.paths.phase2Audio, 'x_original.wav');

if ~exist(musicFile, 'file')
    error('Required Phase 1 file not found: %s', musicFile);
end

if ~exist(voiceFile, 'file')
    error('Required Phase 2 file not found: %s', voiceFile);
end

[music, fsMusic] = audioread(musicFile);
[voice, fsVoice] = audioread(voiceFile);

if fsMusic ~= fsVoice
    error('Phase 1 music and Phase 2 voice must have the same sample rate.');
end

fs = fsVoice;

if size(music, 2) > 1
    music = mean(music, 2);
end

if size(voice, 2) > 1
    voice = mean(voice, 2);
end

music = music(:);
voice = voice(:);

music = music - mean(music);
voice = voice - mean(voice);

music = normalize_audio(music, 0.95);
voice = normalize_audio(voice, 0.95);

% Match the synthetic music to the exact voice duration.
musicMatched = match_signal_length(music, numel(voice));

% Studio mix: keep the voice dominant and the synthesized tone in the
% background.
studioRaw = ...
    cfg.phase3.voiceGain * voice + ...
    cfg.phase3.musicGain * musicMatched;

studio = normalize_audio(studioRaw, 0.95);

studioFile = fullfile(cfg.paths.phase3Audio, 'x_studio.wav');
audiowrite(studioFile, studio, fs);

delaySamples = round(cfg.phase3.delaySeconds * fs);
alphaStable = cfg.phase3.alphaStable;
alphaUnstable = cfg.phase3.alphaUnstable;
firTapCount = cfg.phase3.firTapCount;

% FIR echo:
% h_FIR[n] = sum_{k=0}^{M-1} alpha^k delta[n-kR]
hFir = zeros((firTapCount - 1) * delaySamples + 1, 1);

for k = 0:firTapCount - 1
    hFir(k * delaySamples + 1) = alphaStable^k;
end

yFirRaw = conv(studio, hFir);
yFir = normalize_audio(yFirRaw, 0.95);

% Stable recursive IIR:
% y[n] = x[n] + alpha*y[n-R], |alpha| < 1
yIirStableRaw = recursive_echo(studio, delaySamples, alphaStable);
yIirStable = normalize_audio(yIirStableRaw, 0.95);

% Unstable recursive IIR:
% y[n] = x[n] + alpha*y[n-R], |alpha| > 1
yIirUnstableRaw = recursive_echo(studio, delaySamples, alphaUnstable);
yIirUnstable = normalize_audio(yIirUnstableRaw, 0.95);

firFile = fullfile(cfg.paths.phase3Audio, 'y_fir_stable.wav');
iirStableFile = fullfile(cfg.paths.phase3Audio, 'y_iir_stable.wav');
iirUnstableFile = fullfile(cfg.paths.phase3Audio, 'y_iir_unstable.wav');

audiowrite(firFile, yFir, fs);
audiowrite(iirStableFile, yIirStable, fs);
audiowrite(iirUnstableFile, yIirUnstable, fs);

fprintf('Created: %s\n', studioFile);
fprintf('Created: %s\n', firFile);
fprintf('Created: %s\n', iirStableFile);
fprintf('Created: %s\n', iirUnstableFile);

% FIR impulse response figure.
tFir = (0:numel(hFir)-1).' / fs;

figFir = figure( ...
    'Name', 'Phase 3 - FIR Impulse Response', ...
    'Color', 'w');

stem(tFir, hFir, 'filled', 'LineWidth', 1.0);
grid on;
title('FIR Echo Impulse Response');
xlabel('Time (s)');
ylabel('h_{FIR}[n]');
xlim([0 tFir(end) + cfg.phase3.delaySeconds / 4]);

firFigurePath = fullfile( ...
    cfg.paths.phase3Figures, 'phase3_fir_impulse_response.png');

drawnow;
exportgraphics(figFir, firFigurePath, 'Resolution', 300);

% Finite impulse-response views for stable and unstable recursive systems.
impulseLength = round(cfg.phase3.displaySeconds * fs);
unitImpulse = zeros(impulseLength, 1);
unitImpulse(1) = 1;

hIirStable = recursive_echo(unitImpulse, delaySamples, alphaStable);
hIirUnstable = recursive_echo(unitImpulse, delaySamples, alphaUnstable);

tImpulse = (0:impulseLength-1).' / fs;

figIirImpulse = figure( ...
    'Name', 'Phase 3 - IIR Impulse Responses', ...
    'Color', 'w');

subplot(2, 1, 1);
stem(tImpulse, hIirStable, 'filled', 'LineWidth', 0.9);
grid on;
title(sprintf('Stable IIR Impulse Response, \\alpha = %.2f', alphaStable));
xlabel('Time (s)');
ylabel('h[n]');
xlim([0 cfg.phase3.displaySeconds]);

subplot(2, 1, 2);
stem(tImpulse, hIirUnstable, 'filled', 'LineWidth', 0.9);
grid on;
title(sprintf('Unstable IIR Impulse Response, \\alpha = %.2f', alphaUnstable));
xlabel('Time (s)');
ylabel('h[n]');
xlim([0 cfg.phase3.displaySeconds]);

iirImpulseFigurePath = fullfile( ...
    cfg.paths.phase3Figures, 'phase3_iir_impulse_responses.png');

drawnow;
exportgraphics(figIirImpulse, iirImpulseFigurePath, 'Resolution', 300);

% Compare output waveforms using the unnormalized recursive outputs to make
% the unstable growth visible.
displaySamples = min( ...
    round(cfg.phase3.displaySeconds * fs), ...
    numel(studio));

tDisplay = (0:displaySamples-1).' / fs;

figComparison = figure( ...
    'Name', 'Phase 3 - Output Comparison', ...
    'Color', 'w');

subplot(3, 1, 1);
plot(tDisplay, studio(1:displaySamples), 'LineWidth', 0.8);
grid on;
title('Studio Mix');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(tDisplay, yIirStableRaw(1:displaySamples), 'LineWidth', 0.8);
grid on;
title(sprintf('Stable IIR Echo, \\alpha = %.2f', alphaStable));
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(tDisplay, yIirUnstableRaw(1:displaySamples), 'LineWidth', 0.8);
grid on;
title(sprintf('Unstable IIR Echo, \\alpha = %.2f', alphaUnstable));
xlabel('Time (s)');
ylabel('Amplitude');

comparisonFigurePath = fullfile( ...
    cfg.paths.phase3Figures, 'phase3_output_comparison.png');

drawnow;
exportgraphics(figComparison, comparisonFigurePath, 'Resolution', 300);

% Save numerical summary.
summaryTable = table( ...
    ["Studio"; "FIRStable"; "IIRStable"; "IIRUnstable"], ...
    [numel(studio); numel(yFirRaw); ...
     numel(yIirStableRaw); numel(yIirUnstableRaw)], ...
    [max(abs(studio)); max(abs(yFirRaw)); ...
     max(abs(yIirStableRaw)); max(abs(yIirUnstableRaw))], ...
    'VariableNames', {'Signal', 'NumberOfSamples', 'RawPeak'});

summaryPath = fullfile(cfg.paths.results, 'phase3_summary.csv');
writetable(summaryTable, summaryPath);

results.fs = fs;
results.delaySeconds = cfg.phase3.delaySeconds;
results.delaySamples = delaySamples;
results.alphaStable = alphaStable;
results.alphaUnstable = alphaUnstable;
results.firTapCount = firTapCount;
results.hFir = hFir;
results.hIirStable = hIirStable;
results.hIirUnstable = hIirUnstable;
results.audioFiles = { ...
    studioFile, firFile, iirStableFile, iirUnstableFile};
results.figureFiles = { ...
    firFigurePath, iirImpulseFigurePath, comparisonFigurePath};

save(fullfile(cfg.paths.results, 'phase3_results.mat'), 'results');

fprintf('Created: %s\n', firFigurePath);
fprintf('Created: %s\n', iirImpulseFigurePath);
fprintf('Created: %s\n', comparisonFigurePath);
fprintf('Created: %s\n', summaryPath);

if cfg.phase3.playAudio
    fprintf('Playing studio mix...\n');
    sound(studio, fs);
    pause(numel(studio) / fs + 0.5);

    fprintf('Playing FIR echo...\n');
    sound(yFir, fs);
    pause(numel(yFir) / fs + 0.5);

    fprintf('Playing stable IIR echo...\n');
    sound(yIirStable, fs);
    pause(numel(yIirStable) / fs + 0.5);

    fprintf('Playing unstable IIR echo...\n');
    sound(yIirUnstable, fs);
end

fprintf('Phase 3 script finished successfully.\n');
end
