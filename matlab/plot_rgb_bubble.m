function plot_rgb_bubble(img, varargin)
% SYNTAX
%   plot_rgb_bubble(img)
%   plot_rgb_bubble(img, Name, Value, ...)
% where
%   img:            m*n*3 image. It is treated as RGB image.
% name-value options
%   'BinNum':           integer, default 20
%   'BubbleScale':      scalar, default 2e4
%   'SubsampleStep':    integer, default 20
%   'Background':       3-length vector
%   'AxisColor':        3-length vector
%   'GridColor':        3-length vector
%   'GridAlpha':        3-length vector

p = inputParser;
p.addRequired('img', @(x) validateattributes(x, {'numeric'}, {'size', [NaN, NaN, 3]}));
p.addOptional('BinNum', 20, @(x) validateattributes(x, {'numeric'}, {'integer'}));
p.addOptional('BubbleScale', 2e4, @(x) validateattributes(x, {'numeric'}, {'positive'}));
p.addOptional('SubsampleStep', 20, @(x) validateattributes(x, {'numeric'}, {'integer'}));
p.addOptional('Background', [13, 13, 13] / 255, @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'numel', 3, '>=', 0, '<=', 1}));
p.addOptional('AxisColor', [1, 1, 1] * 0.75, @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'numel', 3, '>=', 0, '<=', 1}));
p.addOptional('GridColor', [1, 1, 1], @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'numel', 3, '>=', 0, '<=', 1}));
p.addOptional('GridAlpha', 0.2, @(x) validateattributes(x, {'numeric'}, {'scalar', '>=', 0, '<=', 1}));
p.parse(img, varargin{:});

img_vec = reshape(img, [], 3);
img_vec = img_vec(1:p.Results.SubsampleStep:end, :);

bin_size = 1 / p.Results.BinNum;
img_subs = min(floor(img_vec / bin_size) + 1, p.Results.BinNum);
img_ind = sub2ind([1, 1, 1] * p.Results.BinNum, img_subs(:, 1), img_subs(:, 2), img_subs(:, 3));

bin_cnt = accumarray(img_ind, 1, [p.Results.BinNum ^ 3, 1]);
valid_bin_ind = bin_cnt > 0;
bin_ind = find(valid_bin_ind);
bin_cnt = bin_cnt(valid_bin_ind);
bin_cnt = bin_cnt / sum(bin_cnt(:));
[bin_subs1, bin_subs2, bin_subs3] = ind2sub([1, 1, 1] * p.Results.BinNum, bin_ind);
bin_centers_offset = randn(size(bin_subs1, 1), 3) * bin_size * 0.2;
bin_centers = ([bin_subs1, bin_subs2, bin_subs3] - 1) * bin_size + bin_centers_offset;
bin_colors = bin_centers - bin_centers_offset;

scatter3(bin_centers(:, 1), bin_centers(:, 2), bin_centers(:, 3), ...
    bin_cnt * p.Results.BubbleScale, bin_colors, 'fill');
axis equal;
set(gcf, 'Color', p.Results.Background, 'InvertHardCopy', 'off');
set(gca, 'XLim', [0, 1], 'YLim', [0, 1], 'ZLim', [0, 1], ...
    'XTick', 0:.2:1, 'YTick', 0:.2:1, 'ZTick', 0:.2:1, ...
    'XColor', p.Results.AxisColor, 'YColor', p.Results.AxisColor, 'ZColor', p.Results.AxisColor, ...
    'FontSize', 14);
set(gca, 'GridColor', p.Results.GridColor, 'GridAlpha', p.Results.GridAlpha, 'Color', 'none', ...
    'Projection', 'perspective');
end
