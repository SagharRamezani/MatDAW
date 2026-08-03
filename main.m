clear;
clc;
close all;

projectRoot = fileparts(mfilename('fullpath'));
cd(projectRoot);
addpath(genpath(projectRoot));

cfg = config();

requiredFolders = {
    cfg.paths.phase1Audio
    cfg.paths.phase1Figures
    cfg.paths.phase2Audio
    cfg.paths.phase2Figures
    cfg.paths.phase3Audio
    cfg.paths.phase3Figures
    cfg.paths.phase4Audio
    cfg.paths.phase4Figures
    cfg.paths.results
};

for i = 1:numel(requiredFolders)
    if ~exist(requiredFolders{i}, 'dir')
        mkdir(requiredFolders{i});
    end
end

fprintf('MatDAW integrated execution started.\n');
fprintf('Project root: %s\n\n', projectRoot);

% The original voice recording must already exist. This integrated run does
% not activate the microphone.
requiredRecording = fullfile(cfg.paths.phase2Audio, 'x_original.wav');
if ~exist(requiredRecording, 'file')
    error(['Required recording not found: ' requiredRecording newline ...
        'Run phase2_record_audio(config()) once before integrated execution.']);
end

phase1_synthesizer(cfg);
close all;

phase2_resample_analysis(cfg);
close all;

phase3_echo_processing(cfg);
close all;

phase4_equalizer(cfg);
close all;

validation = final_validation(cfg);

fprintf('\nIntegrated execution finished successfully.\n');
fprintf('Validation passed: %d/%d checks.\n', ...
    validation.PassedChecks, validation.TotalChecks);
