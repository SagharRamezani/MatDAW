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
    cfg.paths.results
};

for i = 1:numel(requiredFolders)
    if ~exist(requiredFolders{i}, 'dir')
        mkdir(requiredFolders{i});
    end
end

fprintf('MatDAW started.\n');
fprintf('Project root: %s\n\n', projectRoot);

runPhase1 = true;
runPhase2 = false;
runPhase3 = false;
runPhase4 = false;

if runPhase1
    phase1_synthesizer(cfg);
end

if runPhase2
    warning('Phase 2 has not been implemented yet.');
end

if runPhase3
    warning('Phase 3 has not been implemented yet.');
end

if runPhase4
    warning('Phase 4 has not been implemented yet.');
end

fprintf('\nSelected project phases finished.\n');
