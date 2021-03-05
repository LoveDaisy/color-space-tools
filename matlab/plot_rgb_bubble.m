function plot_rgb_bubble(varargin)
% SYNTAX
%   plot_rgb_bubble(img, Name, Value, ...)
%   plot_rgb_bubble([], center, Name, Value, ...)
%   plot_rgb_bubble([], center, size, ...)
%   plot_rgb_bubble([], center, size, color, Name, Value, ...)
%
% If 'Image' is set, this function will ignore 'Center', 'Size', and 'Color' options.
%
% name-value options
%   'Image':            m*n*3 image
%   'Center':           m*3 bubble center
%   'Size':             m-length bubble size, can be empty
%   'Color':            m*3 bubble color, can be empty
%
%   'BinNum':           integer, default 20
%   'BubbleScale':      scalar, default 2e4
%   'SubsampleStep':    integer, default 20
%   'Background':       3-length vector
%   'AxisColor':        3-length vector
%   'GridColor':        3-length vector
%   'GridAlpha':        3-length vector

p0 = inputParser;
p0.addOptional('Image', [], @validate_image);
p0.addOptional('Center', [], @(x) validateattributes(x, {'numeric'}, {'size', [NaN, 3]}));
p0.addOptional('Size', [], @(x) validateattributes(x, {'numeric'}, {'vector'}));
p0.addOptional('Color', [], @(x) validateattributes(x, {'numeric'}, {'size', [NaN, 3]}));

p0.addOptional('BinNum', 20, @(x) validateattributes(x, {'numeric'}, {'integer'}));
p0.addOptional('BubbleScale', 2e4, @(x) validateattributes(x, {'numeric'}, {'positive'}));
p0.addOptional('SubsampleStep', 20, @(x) validateattributes(x, {'numeric'}, {'integer'}));
p0.addOptional('Background', [13, 13, 13] / 255, @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'numel', 3, '>=', 0, '<=', 1}));
p0.addOptional('AxisColor', [1, 1, 1] * 0.75, @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'numel', 3, '>=', 0, '<=', 1}));
p0.addOptional('GridColor', [1, 1, 1], @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'numel', 3, '>=', 0, '<=', 1}));
p0.addOptional('GridAlpha', 0.2, @(x) validateattributes(x, {'numeric'}, {'scalar', '>=', 0, '<=', 1}));
p0.parse(varargin{:});

if ~isempty(p0.Results.Image)
    [bin_colors, bin_cnt] = rgb_hist3_count(p0.Results.Image, 'BinNum', p0.Results.BinNum, ...
        'SubsampleStep', p0.Results.SubsampleStep);
    bin_cnt = bin_cnt / sum(bin_cnt(:)) * p0.Results.BubbleScale;
    bin_size = 1 / p0.Results.BinNum;
    bin_centers_offset = randn(size(bin_colors)) * bin_size * 0.2;
    bin_centers = bin_colors + bin_centers_offset;
elseif ~isempty(p0.Results.Center)
    bin_centers = p0.Results.Center;
    total_bin_num = size(bin_centers, 1);
    if ~isempty(p0.Results.Size)
        bin_cnt = p0.Results.Size;
        if length(bin_cnt) ~= total_bin_num
            error('Size must be the same length as Center!');
        end
    else
        bin_cnt = ones(total_bin_num, 1) * 10;
    end

    if ~isempty(p0.Results.Color)
        bin_colors = p0.Results.Color;
        if size(bin_colors, 1) ~= total_bin_num
            error('Color must be the same length as Center!');
        end
    else
        color_map = colormap('lines');
        bin_colors = repmat(color_map(1, :), total_bin_num, 1);
    end
else
    error('Image & Center cannot be all empty!');
end

scatter3(bin_centers(:, 1), bin_centers(:, 2), bin_centers(:, 3), ...
    bin_cnt, bin_colors, 'fill');
axis equal;
set(gcf, 'Color', p0.Results.Background, 'InvertHardCopy', 'off');
set(gca, 'XLim', [0, 1], 'YLim', [0, 1], 'ZLim', [0, 1], ...
    'XTick', 0:.2:1, 'YTick', 0:.2:1, 'ZTick', 0:.2:1, ...
    'XColor', p0.Results.AxisColor, 'YColor', p0.Results.AxisColor, 'ZColor', p0.Results.AxisColor, ...
    'FontSize', 14);
set(gca, 'GridColor', p0.Results.GridColor, 'GridAlpha', p0.Results.GridAlpha, 'Color', 'none', ...
    'Projection', 'perspective');
end


function res = validate_image(x)
if isempty(x)
    res = true;
    return;
else
    res = true;
    validateattributes(x, {'numeric'}, {'size', [NaN, NaN, 3]});
end
end
