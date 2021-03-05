function [rgb2yuv, yuv2rgb] = get_rgbyuv_matrix(name)
% Get the conversion matrix for RGB2YUV, YUV2RGB, RGB2XYZ, XYZ2RGB
% INPUT
%  name:    a string indicates color space
%             1. FCC: FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
%             2. BT470BG: also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
%             3. SMPTE170M: also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
%             4. BT709: also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
%             5. SMPTE240M: functionally identical to SMPTE170M
%             6. YCOCG: Used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
%             7. YCGCO: identical to above
%             8. RGB: IEC 61966-2-1 (sRGB)
%             9. BT2020_NCL: ITU-R BT2020 non-constant luminance system
%            10. BT2020_CL: ITU-R BT2020 constant luminance system

rgb2yuv = get_rgb2yuv_mat(get_yuv_luma_coefficient(name));
yuv2rgb = inv(rgb2yuv);
end


function coef = get_yuv_luma_coefficient(name)
% Return the luma coefficients. The luma coefficients are used in RGB2YUV conversion like:
%   Y = C1 * R + C2 * G + C3 * B
% INPUT
%  name:    a string indicates color space
%             1. FCC: FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
%             2. BT470BG: also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
%             3. SMPTE170M: also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
%             4. BT709: also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
%             5. SMPTE240M: functionally identical to SMPTE170M
%             6. YCOCG: Used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
%             7. YCGCO: identical to above
%             8. RGB: IEC 61966-2-1 (sRGB)
%             9. BT2020_NCL: ITU-R BT2020 non-constant luminance system
%            10. BT2020_CL: ITU-R BT2020 constant luminance system

if strcmpi(name, 'FCC')
    coef = [ 0.30, 0.59, 0.11 ];
elseif strcmpi(name, 'BT470BG')
    coef = [ 0.299, 0.587, 0.114 ];
elseif strcmpi(name, 'SMPTE170M')
    coef = [ 0.299, 0.587, 0.114 ];
elseif strcmpi(name, 'BT709')
    coef = [ 0.2126, 0.7152, 0.0722 ];
elseif strcmpi(name, 'SMPTE240M')
    coef = [ 0.212, 0.701, 0.087 ];
elseif strcmpi(name, 'YCOCG') || strcmpi(name, 'YCGCO')
    coef = [ 0.25, 0.5, 0.25 ];
elseif strcmpi(name, 'RGB')
    coef = [ 1, 1, 1 ];
elseif strcmpi(name, 'BT2020_NCL')
    coef = [ 0.2627, 0.6780, 0.0593 ];
elseif strcmpi(name, 'BT2020_CL')
    coef = [ 0.2627, 0.6780, 0.0593 ];
else
    coef = [ 1, 1, 1 ];
end
end


function rgb2yuv = get_rgb2yuv_mat(coef)
% special ycgco matrix
if norm(coef - get_yuv_luma_coefficient('YCOCG')) < 1e-4
    rgb2yuv = [ 0.25, 0.5, 0.25;
        -0.25, 0.5, -0.25;
        0.5, 0, -0.5 ];
elseif norm(coef - get_yuv_luma_coefficient('RGB')) < 1e-4
    rgb2yuv = [ 0, 1, 0;
        0, -0.5, 0.5;
        0.5, -0.5, 0 ];
else
bscale = 0.5 / (coef(3) - 1.0);
rscale = 0.5 / (coef(1) - 1.0);
rgb2yuv = [ coef(1), coef(2), coef(3);
    bscale * coef(1), bscale * coef(2), 0.5;
    0.5, rscale * coef(2), rscale * coef(3) ];
end
end
