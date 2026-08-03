function cfg = config()
%CONFIG Central configuration for the MatDAW project.

cfg.projectRoot = fileparts(mfilename('fullpath'));

% Common paths
cfg.paths.phase1Audio   = fullfile(cfg.projectRoot, 'audio', 'phase1');
cfg.paths.phase1Figures = fullfile(cfg.projectRoot, 'figures', 'phase1');
cfg.paths.results       = fullfile(cfg.projectRoot, 'results');

% Phase 1 settings
cfg.phase1.fs = 44100;
cfg.phase1.f0 = 440;
cfg.phase1.duration = 10;
cfg.phase1.amplitude = 1;

% State A: fundamental only
cfg.phase1.harmonicsA = 1;

% State B: first five odd harmonics
cfg.phase1.harmonicsB = [1 3 5 7 9];

% State C: harmonics k = 1,...,50.
% Even coefficients are zero for this triangle-wave definition.
cfg.phase1.harmonicsC = 1:50;

% Playback is disabled by default to avoid automatic long playback.
cfg.phase1.playAudio = false;

% Display only a few periods in the time-domain figure.
cfg.phase1.displayPeriods = 3;
end
