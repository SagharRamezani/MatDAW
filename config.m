function cfg = config()
%CONFIG Central configuration for the MatDAW project.

cfg.projectRoot = fileparts(mfilename('fullpath'));

% Common paths
cfg.paths.phase1Audio   = fullfile(cfg.projectRoot, 'audio', 'phase1');
cfg.paths.phase1Figures = fullfile(cfg.projectRoot, 'figures', 'phase1');
cfg.paths.phase2Audio   = fullfile(cfg.projectRoot, 'audio', 'phase2');
cfg.paths.phase2Figures = fullfile(cfg.projectRoot, 'figures', 'phase2');
cfg.paths.results       = fullfile(cfg.projectRoot, 'results');

% Phase 1 settings
cfg.phase1.fs = 44100;
cfg.phase1.f0 = 440;
cfg.phase1.duration = 10;
cfg.phase1.amplitude = 1;
cfg.phase1.harmonicsA = 1;
cfg.phase1.harmonicsB = [1 3 5 7 9];
cfg.phase1.harmonicsC = 1:50;
cfg.phase1.playAudio = false;
cfg.phase1.displayPeriods = 3;

% Phase 2 settings
cfg.phase2.fsOriginal = 44100;
cfg.phase2.fsReduced = 8000;
cfg.phase2.duration = 10;
cfg.phase2.bitsPerSample = 16;
cfg.phase2.channels = 1;
cfg.phase2.filterOrder = 8;
cfg.phase2.cutoffHz = 3800;
cfg.phase2.playAudio = false;

% Recording and processing are separated so the microphone is not
% activated every time main.m is executed.
cfg.phase2.recordNewAudio = false;
end
