function [rgb2xyz, xyz2rgb] = get_rgbxyz_matrix(name)
% Get conversion matrix between RGB and XYZ
% INPUT
%  name:  the same as function get_color_primaries(name)

pri = get_color_primaries(name);
rgb2xyz = [ pri.r(1) / pri.r(2), pri.g(1) / pri.g(2), pri.b(1) / pri.b(2);
    1, 1, 1;
    pri.r(3) / pri.r(2), pri.g(3) / pri.g(2), pri.b(3) / pri.b(2) ];
s = rgb2xyz \ pri.wp';
rgb2xyz = rgb2xyz * diag(s);
xyz2rgb = inv(rgb2xyz);
end