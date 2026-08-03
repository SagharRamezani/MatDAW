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
    cfg.paths.results
};

for i = 1:numel(requiredFolders)
    if ~exist(requiredFolders{i}, 'dir')
        mkdir(requiredFolders{i});
    end
end

fprintf('MatDAW started.\n');
fprintf('Project root: %s\n\n', projectRoot);

runPhase1 = false;
runPhase2 = false;
runPhase3 = true;
runPhase4 = false;

if runPhase1
    phase1_synthesizer(cfg);
end

if runPhase2
    if cfg.phase2.recordNewAudio
        phase2_record_audio(cfg);
    end
    phase2_resample_analysis(cfg);
end

if runPhase3
    phase3_echo_processing(cfg);
end

if runPhase4
    warning('Phase 4 has not been implemented yet.');
end

fprintf('\nSelected project phases finished.\n');
