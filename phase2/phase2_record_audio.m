function outputFile = phase2_record_audio(cfg)
%PHASE2_RECORD_AUDIO Record the required approximately 10-second sentence.
%
% Read this sentence during recording:
% "Hello, my name is [First Name] [Last Name], student ID [Student ID],
% majoring in Computer Engineering at K. N. Toosi University."

fprintf('--- Phase 2: Voice recording ---\n');

fs = cfg.phase2.fsOriginal;
duration = cfg.phase2.duration;
bits = cfg.phase2.bitsPerSample;
channels = cfg.phase2.channels;

outputFile = fullfile(cfg.paths.phase2Audio, 'x_original.wav');

fprintf('\nPrepare to read the required sentence clearly.\n');
fprintf('Recording duration: %.1f seconds\n', duration);
fprintf('Recording starts in 3 seconds...\n');

pause(1);
fprintf('3...\n');
pause(1);
fprintf('2...\n');
pause(1);
fprintf('1...\n');
pause(1);
fprintf('Recording now.\n');

recorder = audiorecorder(fs, bits, channels);
recordblocking(recorder, duration);

fprintf('Recording finished.\n');

x = getaudiodata(recorder, 'double');
x = x - mean(x);
x = normalize_audio(x, 0.95);

audiowrite(outputFile, x, fs);

fprintf('Created: %s\n', outputFile);
end
