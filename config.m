function cfg = config()
%CONFIG Central configuration for the MatDAW project.

cfg.projectRoot = fileparts(mfilename('fullpath'));

% Common paths
cfg.paths.phase1Audio   = fullfile(cfg.projectRoot, 'audio', 'phase1');
cfg.paths.phase1Figures = fullfile(cfg.projectRoot, 'figures', 'phase1');
cfg.paths.phase2Audio   = fullfile(cfg.projectRoot, 'audio', 'phase2');
cfg.paths.phase2Figures = fullfile(cfg.projectRoot, 'figures', 'phase2');
cfg.paths.phase3Audio   = fullfile(cfg.projectRoot, 'audio', 'phase3');
cfg.paths.phase3Figures = fullfile(cfg.projectRoot, 'figures', 'phase3');
cfg.paths.phase4Audio   = fullfile(cfg.projectRoot, 'audio', 'phase4');
cfg.paths.phase4Figures = fullfile(cfg.projectRoot, 'figures', 'phase4');
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
cfg.phase2.recordNewAudio = false;

% Phase 3 settings
cfg.phase3.delaySeconds = 0.4;
cfg.phase3.alphaStable = 0.6;
cfg.phase3.alphaUnstable = 1.05;
cfg.phase3.firTapCount = 5;
cfg.phase3.voiceGain = 1.20;
cfg.phase3.musicGain = 0.25;
cfg.phase3.playAudio = false;
cfg.phase3.displaySeconds = 5;

% Phase 4 settings
cfg.phase4.lowCutoffHz = 300;
cfg.phase4.highCutoffHz = 2000;

% Overall filter orders:
% Low-pass: 4
% Band-pass: 4 overall. MATLAB butter(2,[w1 w2],'bandpass')
% creates a fourth-order band-pass transfer function.
% High-pass: 4
cfg.phase4.lowpassOrder = 4;
cfg.phase4.bandpassPrototypeOrder = 2;
cfg.phase4.highpassOrder = 4;

cfg.phase4.bassBoostGains = [2.5 1.0 0.5];
cfg.phase4.muffledGains = [2.0 0.1 0.1];

cfg.phase4.impulseLength = 512;
cfg.phase4.playAudio = false;
end
