function trc = get_transfer_characteristics(name)
% INPUT
%  name:  a string indicates the name of transfer characteristics.
%         it must be one of (ignore cases):
%           1. BT709, i.e. ITU-R BT1361
%           2. GAMMA22, i.e. ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
%           3. GAMMA28, i.e. ITU-R BT470BG
%           4. SMPTE170M, i.e. ITU-R BT601-6 525 or 625 / ITU-R BT1358 525 or 625 / ITU-R BT1700 NTSC
%           5. SMPTE240M
%           6. IEC61966_2_1, i.e. IEC 61966-2-1 (sRGB or sYCC)
%           7. IEC61966_2_4, i.e. IEC 61966-2-4
%           8. BT2020_10, i.e. ITU-R BT2020 for 10-bit system
%           9. BT2020_12, i.e. ITU-R BT2020 for 12-bit system
% OUTPUT
%  trc:  a struct contains two functions, one de-linearize function and
%        one linearize function

if strcmpi(name, 'BT709')
    coef = [ 1.099, 0.018, 0.45, 4.5 ];
elseif strcmpi(name, 'GAMMA22')
    coef = [ 1.0, 0.0, 1.0 / 2.2, 0.0 ];
elseif strcmpi(name, 'GAMMA28')
    coef = [ 1.0, 0.0, 1.0 / 2.8, 0.0 ];
elseif strcmpi(name, 'SMPTE170M')
    coef = [ 1.099, 0.018, 0.45, 4.5 ];
elseif strcmpi(name, 'SMPTE240M')
    coef = [ 1.1115, 0.0228, 0.45, 4.0 ];
elseif strcmpi(name, 'IEC61966_2_1') || strcmpi(name, 'SRGB') || strcmpi(name, 'SYCC')
    coef = [ 1.055, 0.0031308, 1.0 / 2.4, 12.92 ];
elseif strcmpi(name, 'IEC61966_2_4')
    coef = [ 1.099, 0.018, 0.45, 4.5 ];
elseif strcmpi(name, 'BT2020_10')
    coef = [ 1.099, 0.018, 0.45, 4.5 ];
elseif strcmpi(name, 'BT2020_12')
    coef = [ 1.0993, 0.0181, 0.45, 4.5 ];
else
    warning('Cannot find color primaries for %s, use default values!', name);
    coef = [ 1.0, 0.0, 1.0, 1.0 ];
end
trc.de_lin = @(x) delinearize(coef, x);
trc.lin = @(x) linearize(coef, x);
end


function y = delinearize(coef, x)
% De-linearize
lin_idx = abs(x) < coef(2);
y = x .* coef(4) .* lin_idx + ...
    (coef(1) * abs(x) .^ coef(3) - coef(1) + 1) .* sign(x) .* (~lin_idx);
end


function y = linearize(coef, x)
% Linearize
lin_idx = abs(x) < coef(2) * coef(4);
y = x ./ coef(4) .* lin_idx + ...
    ((abs(x) + coef(1) - 1) ./ coef(1)) .^ (1 / coef(3)) .* sign(x) .* (~lin_idx);
end