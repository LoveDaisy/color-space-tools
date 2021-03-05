function [center, cnt] = rgb_hist3_count(img, varargin)
% SYNTAX
%   [center, cnt] = rgb_hist3_count(img)
% where
%   img:        m*n*3 image
%   center:     k*3
%   cnt:        k*1
% name-value options
%   'BinNum':           integer, default 20
%   'SubsampleStep':    integer, default 20


p0 = inputParser;
p0.addRequired('img', @(x) validateattributes(x, {'numeric'}, {'size', [NaN, NaN, 3]}));
p0.addOptional('BinNum', 20, @(x) validateattributes(x, {'numeric'}, {'integer'}));
p0.addOptional('SubsampleStep', 20, @(x) validateattributes(x, {'numeric'}, {'integer'}));
p0.parse(img, varargin{:});

img_vec = reshape(img, [], 3);
img_vec = img_vec(1:p0.Results.SubsampleStep:end, :);

bin_size = 1 / p0.Results.BinNum;
img_subs = min(floor(img_vec / bin_size) + 1, p0.Results.BinNum);
img_ind = sub2ind([1, 1, 1] * p0.Results.BinNum, img_subs(:, 1), img_subs(:, 2), img_subs(:, 3));

bin_cnt = accumarray(img_ind, 1, [p0.Results.BinNum ^ 3, 1]);
valid_bin_ind = bin_cnt > 0;
bin_ind = find(valid_bin_ind);
cnt = bin_cnt(valid_bin_ind);
[bin_subs1, bin_subs2, bin_subs3] = ind2sub([1, 1, 1] * p0.Results.BinNum, bin_ind);
center = ([bin_subs1, bin_subs2, bin_subs3] - 1) * bin_size;
end