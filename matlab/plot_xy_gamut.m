function plot_xy_gamut(varargin)
% SYNTAX
%   plot_xy_gamut
%   plot_xy_gamut(Name, Value, ...)
%
% the default output colorspace is sRGB
%
% name-value options:
%   'GamutBoundary':        {true} | false
%   'ImageSize':            {800} an integer

p0 = inputParser;
p0.addOptional('GamutBoundary', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
p0.addOptional('ImageSize', 800, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}));
p0.parse(varargin{:});

[xy, ~, ~, k] = get_cmf_boundary();

x_side = linspace(0, 1, p0.Results.ImageSize);
y_side = x_side;
[gamut_x, gamut_y, gamut_z] = build_gamut_mesh(x_side, y_side);
gamut_mask = make_gamut_mask(gamut_x, gamut_y, xy, k);

rgb_base = get_rgb_base('sRGB');
rgb_lin = [gamut_x(:), gamut_y(:), gamut_z(:)] / rgb_base;
rgb = nonlinearize_rgb(rgb_lin);
rgb = reshape(rgb, [length(y_side), length(x_side), 3]);

im = imagesc(x_side, y_side, rgb);
im.AlphaData = gamut_mask;
ax = gca;
hold_state = ax.NextPlot;

hold on;
if p0.Results.GamutBoundary
    plot(xy(k, 1), xy(k, 2), 'k');
end
ax.NextPlot = hold_state;
end


function [xy, XYZ, wl, k] = get_cmf_boundary()
xyz_2deg_cmf = dlmread('../data/lin2012xyz2e_1_7sf.csv');
XYZ = xyz_2deg_cmf(:, 2:4);
xy = bsxfun(@times, XYZ, 1 ./ sum(XYZ, 2));
wl = xyz_2deg_cmf(:, 1);
k = convhull(xy(:, 1), xy(:, 2));
end


function [gamut_x, gamut_y, gamut_z] = build_gamut_mesh(x_side, y_side)
[gamut_x, gamut_y] = meshgrid(x_side, y_side);
gamut_z = 1 - gamut_x - gamut_y;
end


function gamut_mask = make_gamut_mask(gamut_x, gamut_y, xy, k)
[min_y, min_i] = min(xy(k, 2));
k = circshift(k, -min_i);
[max_y, max_i] = max(xy(k, 2));

x_step = gamut_x(1, 2) - gamut_x(1, 1);
left_yi = [1, 2];
right_yi = [length(k), length(k) - 1];
gamut_mask = zeros(size(gamut_y));
for yi = 1:size(gamut_y, 1)
    y = gamut_y(yi, 1);
    if y < min_y || y > max_y
        gamut_mask(yi, :) = 0;
    else
        while xy(k(left_yi(2)), 2) < y && left_yi(2) < max_i
            left_yi = left_yi + 1;
        end
        while xy(k(right_yi(2)), 2) < y && right_yi(1) > max_i
            right_yi = right_yi - 1;
        end
        [left_x, right_x] = find_intercept_x(left_yi, right_yi, xy, k, y);
        idx = find(gamut_x(yi, :) >= left_x & gamut_x(yi, :) <= right_x);
        gamut_mask(yi, idx) = 1;
        left_xi = min(idx);
        right_xi = max(idx);
        left_frac = (gamut_x(yi, left_xi) - left_x) / x_step + 0.5;
        right_frac = (right_x - gamut_x(yi, right_xi)) / x_step + 0.5;
        if left_frac > 1
            gamut_mask(yi, max(left_xi - 1, 1)) = left_frac - 1;
        else
            gamut_mask(yi, left_xi) = left_frac;
        end
        if right_frac > 1
            gamut_mask(yi, min(right_xi + 1, size(gamut_mask, 2))) = right_frac - 1;
        else
            gamut_mask(yi, right_xi) = right_frac;
        end
    end
end
end


function [left_x, right_x] = find_intercept_x(left_yi, right_yi, xy, k, y)
left_x = (-y * diff(xy(k(left_yi), 1)) + det([xy(k(left_yi), 2), xy(k(left_yi), 1)])) / ...
    -diff(xy(k(left_yi), 2));
right_x = (-y * diff(xy(k(right_yi), 1)) + det([xy(k(right_yi), 2), xy(k(right_yi), 1)])) / ...
    -diff(xy(k(right_yi), 2));
if left_x > right_x
    tmp = left_x;
    left_x = right_x;
    right_x = tmp;
end
end


function rgb = nonlinearize_rgb(rgb_lin)
rgb_max_cmp = max(abs(rgb_lin), [], 2);
d = [1, 1.5, 1.2];
rgb_clip_norm = sqrt(sum((rgb_lin * diag(d)).^2, 2)) / norm(d);
color_factor = [rgb_max_cmp, rgb_clip_norm] * [.5; .5];

rgb = bsxfun(@times, rgb_lin, 1 ./ color_factor);
rgb = srgb_gamma(rgb);
end