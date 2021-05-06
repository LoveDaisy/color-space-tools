function [rgb_base, wp] = get_rgb_base(name)
% SYNTAX
%   [rgb_base, wp] = get_rgb_base(name)

srgb_pri = get_color_primaries(name);
wp = srgb_pri.wp / srgb_pri.wp(2);
w = wp / srgb_pri.rgb;
rgb_base = bsxfun(@times, w(:), srgb_pri.rgb);
end