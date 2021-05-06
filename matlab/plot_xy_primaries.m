function plot_xy_primaries(name)
% SYNTAX
%   plot_xy_primaries(name)

[rgb_base, wp] = get_rgb_base(name);

ax = gca;
hold_state = ax.NextPlot;
hold on;
plot(rgb_base(:, 1) ./ sum(rgb_base, 2), rgb_base(:, 2) ./ sum(rgb_base, 2), 'ks');
plot(wp(1) / sum(wp), wp(2) / sum(wp), 'ko');
ax.NextPlot = hold_state;
end