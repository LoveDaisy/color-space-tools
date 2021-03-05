function pri = get_color_primaries(name)
% Get primaries of color space
% INPUT
%  name:    a string indicates color primary name
%           it must be one of following strings (ignore cases):
%             1. BT709, i.e. ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP177 Annex B
%             2. BT470M, i.e. FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
%             3. BT470BG, i.e. ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
%             4. SMPTE170M, i.e. ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
%             5. SMPTE240M, functionally identical to above
%             6. SMPTE428, i.e. SMPTE ST 428-1 (CIE 1931 XYZ)
%             7. SMPTE431, i.e. SMPTE ST 431-2 (2011) / DCI P3
%             8. SMPTE432, i.e. SMPTE ST 432-1 (2010) / P3 D65 / Display P3
%             9. FILM, i.e. colour filters using Illuminant C
%            10. BT2020, i.e. ITU-R BT2020
%            11. JEDEC_P22, i.e. JEDEC P22 phosphors
% OUTPUT
%   pri:    a struct contains following fields:
%             r, g, b: the xyz coordinates of primary r, g, and b
%             wp:      the xyz coordinates of white point
%             rgb:     a stack of r, g, and b. each row represents a primary.

if strcmpi(name, 'BT709') || strcmpi(name, 'sRGB')
    rgb = [ 0.640, 0.330; 0.300, 0.600; 0.150, 0.060 ];
    wp = get_white_point('D65');
elseif strcmpi(name, 'BT470M')
    rgb = [ 0.670, 0.330; 0.210, 0.710; 0.140, 0.080 ];
    wp = get_white_point('C');
elseif strcmpi(name, 'BT470BG')
    rgb = [ 0.640, 0.330; 0.290, 0.600; 0.150, 0.060 ];
    wp = get_white_point('D65');
elseif strcmpi(name, 'SMPTE170M')
    rgb = [ 0.630, 0.340; 0.310, 0.595; 0.155, 0.070 ];
    wp = get_white_point('D65');
elseif strcmpi(name, 'SMPTE240M')
    rgb = [ 0.630, 0.340; 0.310, 0.595; 0.155, 0.070 ];
    wp = get_white_point('D65');
elseif strcmpi(name, 'SMPTE428')
    rgb = [ 0.735, 0.265; 0.274, 0.718; 0.167, 0.009 ];
    wp = get_white_point('E');
elseif strcmpi(name, 'SMPTE431')
    rgb = [ 0.680, 0.320; 0.265, 0.690; 0.150, 0.060 ];
    wp = get_white_point('DCI');
elseif strcmpi(name, 'SMPTE432') || strcmpi(name, 'DisplayP3')
    rgb = [ 0.680, 0.320; 0.265, 0.690; 0.150, 0.060 ];
    wp = get_white_point('D65');
elseif strcmpi(name, 'FILM')
    rgb = [ 0.681, 0.319; 0.243, 0.692; 0.145, 0.049 ];
    wp = get_white_point('C');
elseif strcmpi(name, 'BT2020')
    rgb = [ 0.708, 0.292; 0.170, 0.797; 0.131, 0.046 ];
    wp = get_white_point('D65');
elseif strcmpi(name, 'JEDEC_P22')
    rgb = [ 0.630, 0.340; 0.295, 0.605; 0.155, 0.077 ];
    wp = get_white_point('D65');
else
    warning('Cannot find color primaries for %s, use default values!', name);
    rgb = [ 1/3, 1/3; 1/3, 1/3; 1/3, 1/3 ];
    wp = get_white_point('D65');
end
pri.rgb = [rgb, 1 - sum(rgb, 2)];
pri.r = pri.rgb(1, :);
pri.g = pri.rgb(2, :);
pri.b = pri.rgb(3, :);
pri.wp = wp;
end


function wp = get_white_point(name)
% Get the white point xy coordinate
% INPUT
%  name:    a string indicates white point.
%           it must be one of following strings (ignore cases):
%             1. D65
%             2. C
%             3. DCI
%             4. E
% OUTPUT
%  wp:      xyz coordinate of white point

if strcmpi(name, 'D65')
    wp = [ 0.3127, 0.3290 ];
elseif strcmpi(name, 'C')
    wp = [ 0.3100, 0.3160 ];
elseif strcmpi(name, 'DCI')
    wp = [ 0.3140, 0.3510 ];
elseif strcmpi(name, 'E')
    wp = [ 1/3.0, 1/3.0 ];
else
    wp = [ 0.3127, 0.3290 ];
end
wp = [wp, 1 - sum(wp)];
end
