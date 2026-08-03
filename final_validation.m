function validation = final_validation(cfg)
%FINAL_VALIDATION Verify required MatDAW deliverables and basic properties.

fprintf('\n--- Final project validation ---\n');

checks = {};
passed = [];
details = {};

    function addCheck(name, condition, detail)
        checks{end+1,1} = name;
        passed(end+1,1) = logical(condition);
        details{end+1,1} = detail;
        if condition
            fprintf('[PASS] %s\n', name);
        else
            fprintf('[FAIL] %s -- %s\n', name, detail);
        end
    end

requiredFiles = {
    fullfile(cfg.paths.phase1Audio, 'x_a.wav'), 44100
    fullfile(cfg.paths.phase1Audio, 'x_b.wav'), 44100
    fullfile(cfg.paths.phase1Audio, 'x_c.wav'), 44100
    fullfile(cfg.paths.phase2Audio, 'x_original.wav'), 44100
    fullfile(cfg.paths.phase2Audio, 'x_naive.wav'), 8000
    fullfile(cfg.paths.phase2Audio, 'x_antialiased.wav'), 8000
    fullfile(cfg.paths.phase3Audio, 'x_studio.wav'), 44100
    fullfile(cfg.paths.phase3Audio, 'y_fir_stable.wav'), 44100
    fullfile(cfg.paths.phase3Audio, 'y_iir_stable.wav'), 44100
    fullfile(cfg.paths.phase3Audio, 'y_iir_unstable.wav'), 44100
    fullfile(cfg.paths.phase4Audio, 'y_bass_boost.wav'), 44100
    fullfile(cfg.paths.phase4Audio, 'y_muffled.wav'), 44100
};

for i = 1:size(requiredFiles,1)
    filePath = requiredFiles{i,1};
    expectedFs = requiredFiles{i,2};
    existsFlag = exist(filePath, 'file') == 2;
    addCheck(['Exists: ' filePath], existsFlag, 'Required audio file is missing.');
    if existsFlag
        info = audioinfo(filePath);
        addCheck(['Sample rate: ' filePath], info.SampleRate == expectedFs, ...
            sprintf('Expected %d Hz, found %d Hz.', expectedFs, info.SampleRate));
        [x, ~] = audioread(filePath);
        peak = max(abs(x(:)));
        addCheck(['No clipping: ' filePath], peak <= 1, ...
            sprintf('Peak amplitude is %.6f.', peak));
        addCheck(['Non-empty: ' filePath], ~isempty(x) && any(abs(x(:)) > 0), ...
            'Audio is empty or completely silent.');
    end
end

requiredFigures = {
    fullfile(cfg.paths.phase1Figures, 'phase1_time_domain.png')
    fullfile(cfg.paths.phase1Figures, 'phase1_state_c_fft.png')
    fullfile(cfg.paths.phase2Figures, 'phase2_spectrum_comparison.png')
    fullfile(cfg.paths.phase2Figures, 'phase2_antialias_filter_response.png')
    fullfile(cfg.paths.phase3Figures, 'phase3_fir_impulse_response.png')
    fullfile(cfg.paths.phase3Figures, 'phase3_iir_impulse_responses.png')
    fullfile(cfg.paths.phase3Figures, 'phase3_output_comparison.png')
    fullfile(cfg.paths.phase4Figures, 'phase4_filter_frequency_responses.png')
    fullfile(cfg.paths.phase4Figures, 'phase4_output_spectra.png')
    fullfile(cfg.paths.phase4Figures, 'phase4_impulse_responses.png')
    fullfile(cfg.paths.phase4Figures, 'phase4_pole_zero_plots.png')
};

for i = 1:numel(requiredFigures)
    addCheck(['Exists: ' requiredFigures{i}], ...
        exist(requiredFigures{i}, 'file') == 2, 'Required figure is missing.');
end

requiredResults = {
    fullfile(cfg.paths.results, 'phase1_harmonics.csv')
    fullfile(cfg.paths.results, 'phase2_summary.csv')
    fullfile(cfg.paths.results, 'phase3_summary.csv')
    fullfile(cfg.paths.results, 'phase4_filter_summary.csv')
};

for i = 1:numel(requiredResults)
    addCheck(['Exists: ' requiredResults{i}], ...
        exist(requiredResults{i}, 'file') == 2, 'Required result file is missing.');
end

phase4Mat = fullfile(cfg.paths.results, 'phase4_results.mat');
if exist(phase4Mat, 'file') == 2
    data = load(phase4Mat, 'results');
    addCheck('Phase 4 low-pass stability', data.results.lowpass.stable, ...
        'Low-pass filter is not stable.');
    addCheck('Phase 4 band-pass stability', data.results.bandpass.stable, ...
        'Band-pass filter is not stable.');
    addCheck('Phase 4 high-pass stability', data.results.highpass.stable, ...
        'High-pass filter is not stable.');
else
    addCheck('Exists: phase4_results.mat', false, 'Phase 4 MAT result is missing.');
end

validationTable = table(checks, passed, details, ...
    'VariableNames', {'Check', 'Passed', 'Details'});

validationPath = fullfile(cfg.paths.results, 'final_validation.csv');
writetable(validationTable, validationPath);

validation.TotalChecks = numel(passed);
validation.PassedChecks = sum(passed);
validation.FailedChecks = sum(~passed);
validation.AllPassed = all(passed);
validation.Table = validationTable;
validation.OutputFile = validationPath;

save(fullfile(cfg.paths.results, 'final_validation.mat'), 'validation');

fprintf('\nValidation summary: %d passed, %d failed.\n', ...
    validation.PassedChecks, validation.FailedChecks);
fprintf('Created: %s\n', validationPath);

if ~validation.AllPassed
    error('Final validation failed. Review the [FAIL] entries above.');
end
end
