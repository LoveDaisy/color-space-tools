clear; close all; clc;


figure(1); clf;
set(gcf, 'Position', [700, 200, 800, 800]);
hold on;

plot_xy_gamut('ImageSize', 1200, 'GamutBoundary', false);
plot_xy_primaries('sRGB');

axis xy; axis equal; axis tight;
grid on;
set(gca, 'xlim', [-.02, .02] + [0, .8], 'ylim', [-.02, .02] + [0, .9], ...
    'fontsize', 16);
box on;