#!/usr/local/bin/python3
# -*- coding: utf-8 -*-

from typing import Union
import numpy as np
import logging
import math


def parse_constant_names(c: type, name: str) -> tuple:
    valid_names = {n: getattr(c, n) for n in dir(c) if
                   not callable(getattr(c, n)) and not n.startswith("__")}

    if name.lower() in set(valid_names.values()):
        name = name.lower()
    elif name.upper() in valid_names.keys():
        name = valid_names[name.upper()]
    else:
        logging.error('Input argument name is not valid!')
        logging.error('Name should be constants in class %s:', type(c).__name__)
        for k in valid_names.keys():
            logging.error('  %s.%s', type(c).__name__, k)
        logging.error('or should be one of the following (ignore cases):')
        for k in valid_names.keys():
            logging.error("  '%s'", k.lower())
        raise RuntimeError('Input argument invalid!')

    alias = [a for a, n in valid_names if n == name]
    return name, alias


class WhitePoint(object):
    D65 = 'd65'
    C = 'c'
    E = 'e'
    DCI = 'dci'

    def get_data(name: str) -> tuple:
        # Returns a 2-length vector

        name, alias = parse_constant_names(WhitePoint, name)

        if name == WhitePoint.D65:
            data = np.array([0.3127, 0.3290])
        elif name == WhitePoint.C:
            data = np.array([0.3100, 0.3160])
        elif name == WhitePoint.DCI:
            data = np.array([0.3140, 0.3510])
        elif name == WhitePoint.E:
            data = np.array([0.3333, 0.3333])
        else:
            logging.warning('White point name not recognize! Use E as default!')
            data = np.array([0.3333, 0.3333])

        return data, name, alias

    def __init__(self, name: str) -> None:
        self.data, self.name, self.alias = WhitePoint.get_data(name)


class ColorPrimaries(object):
    BT709 = 'bt709'
    SRGB = BT709
    BT470BG = 'bt470bg'
    BT601_625 = BT470BG
    SMPTE170M = 'smpte170m'
    SMPTE240M = SMPTE170M
    BT601_525 = SMPTE170M
    BT2020 = 'bt2020'
    BT470M = 'bt470m'
    SMPTE431 = 'smpte431'
    DCI_P3 = SMPTE431
    SMPTE432 = 'smpte432'
    DISPLAY_P3 = SMPTE432

    def get_data(name: str) -> tuple:
        # Returns a 4*2 array: [r, g, b, w]

        name, alias = parse_constant_names(ColorPrimaries, name)

        if name == ColorPrimaries.BT709:
            rgb_xy = np.array([0.640, 0.330, 0.300, 0.600, 0.150, 0.060])
            w = WhitePoint.get_data('d65')
        elif name == ColorPrimaries.BT470BG:
            rgb_xy = np.array([0.640, 0.330, 0.290, 0.600, 0.150, 0.060])
            w = WhitePoint.get_data('d65')
        elif name == ColorPrimaries.SMPTE170M:
            rgb_xy = np.array([0.630, 0.340, 0.310, 0.595, 0.155, 0.070])
            w = WhitePoint.get_data('d65')
        elif name == ColorPrimaries.BT2020:
            rgb_xy = np.array([0.708, 0.292, 0.170, 0.797, 0.131, 0.046])
            w = WhitePoint.get_data('d65')
        elif name == ColorPrimaries.BT470M:
            rgb_xy = np.array([0.670, 0.330, 0.210, 0.710, 0.140, 0.080])
            w = WhitePoint.get_data('c')
        elif name == ColorPrimaries.SMPTE431:
            rgb_xy = np.array([0.680, 0.320, 0.265, 0.690, 0.150, 0.060])
            w = WhitePoint.get_data('dci')
        elif name == ColorPrimaries.SMPTE432:
            rgb_xy = np.array([0.680, 0.320, 0.265, 0.690, 0.150, 0.060])
            w = WhitePoint.get_data('d65')
        else:
            logging.warning('Color primaries name not recognize! Use bt709 as default!')
            rgb_xy = np.array([0.640, 0.330, 0.300, 0.600, 0.150, 0.060])
            w = WhitePoint.get_data('d65')

        return np.vstack((np.reshape(rgb_xy, (3, 2)), w)), name, alias

    def __init__(self, name: str) -> None:
        self.data, self.name, self.alias = ColorPrimaries.get_data(name)
        self.w = self.data[-1, :]
        self.r = self.data[0, :]
        self.g = self.data[1, :]
        self.b = self.data[2, :]


class ColorMatrix(object):
    RGB = 'rgb'
    BT709 = 'bt709'
    BT470BG = 'bt470bg'
    SMPTE170M = 'smpte170m'
    SMPTE240M = SMPTE170M
    BT2020_NCL = 'bt2020_ncl'

    def get_data(name: str) -> tuple:
        # Data is [Cr, Cg, Cb]

        name, alias = parse_constant_names(ColorMatrix, name)

        if name == ColorMatrix.RGB:
            data = np.array([1, 1, 1])
        elif name == ColorMatrix.BT709:
            data = np.array([0.2126, 0.7152, 0.0722])
        elif name == ColorMatrix.BT470BG:
            data = np.array([0.299, 0.587, 0.114])
        elif name == ColorMatrix.SMPTE170M:
            data = np.array([0.299, 0.587, 0.114])
        elif name == ColorMatrix.BT2020_NCL:
            data = np.array([0.2627, 0.6780, 0.0593])
        else:
            logging.warning('Color matrix name not recognize! Use bt709 as default!')
            data = np.array([0.2126, 0.7152, 0.0722])

        return data, name, alias

    def __init__(self, name: str) -> None:
        self.data, self.name, self.alias = ColorMatrix.get_data(name)
        self.Cr = self.data[0]
        self.Cg = self.data[1]
        self.Cb = self.data[2]
        self.rgb2yuv = np.array([])
        self.yuv2rgb = np.array([])


class ColorRange(object):
    LIMITED = 'limited'
    TV = LIMITED
    VIDEO = LIMITED
    FULL = 'full'
    JPEG = FULL


class ColorTransfer(object):
    BT709 = 'bt709'
    SRGB = 'srgb'
    IEC61966_2_1 = SRGB
    IEC61966_2_4 = 'iec61966_2_4'
    SMPTE170M = 'smpte170m'
    BT601_525 = SMPTE170M
    BT470M = SMPTE170M
    SMPTE240M = SMPTE170M
    BT470BG = 'bt470bg'
    BT601_625 = BT470BG
    GAMMA22 = BT470BG
    BT470M = 'bt470m'
    GAMMA28 = BT470M
    BT2020_10 = 'bt2020_10'
    BT2020_12 = 'bt2020_12'
    LINEAR = 'linear'
    SMPTE2084 = 'smpte2084'
    PQ = SMPTE2084
    ARIB_STD_B67 = 'arib_std_b67'
    HLG = ARIB_STD_B67

    def get_data(name: str) -> tuple:
        # Returns a 4-length vector: [alpha, beta, gamma, delta]
        # De-linearize transfer is:
        #   if |x| < beta:  delta * x
        #   else:           (alpha * |x|^gamma + alpha - 1) * sign(x)
        # Linearize transfer is:
        #   if |x| < beta * delta:  x / delta
        #   else:                   ((|x| + alpha - 1) / alpha)^(1/gamma) * sign(x)

        name, alias = parse_constant_names(ColorTransfer, name)

        if name == ColorTransfer.BT709:
            data = np.array([1.099, 0.018, 0.45, 4.5])
        elif name == ColorTransfer.SRGB:
            data = np.array([1.055, 0.0031308, 1.0 / 2.4, 12.92])
        elif name == ColorTransfer.IEC61966_2_4:
            data = np.array([1.099, 0.018, 0.45, 4.5])
        elif name == ColorTransfer.SMPTE170M:
            data = np.array([1.099, 0.018, 0.45, 4.5])
        elif name == ColorTransfer.BT470BG:
            data = np.array([1.0, 0.0, 1.0 / 2.8, 0.0])
        elif name == ColorTransfer.BT470M:
            data = np.array([1.0, 0.0, 1.0 / 2.8, 0.0])
        elif name == ColorTransfer.BT2020_10:
            data = np.array([1.099, 0.018, 0.45, 4.5])
        elif name == ColorTransfer.BT2020_12:
            data = np.array([1.0993, 0.0181, 0.45, 4.5])
        elif name == ColorTransfer.LINEAR or name == ColorTransfer.SMPTE2084 or name == ColorTransfer.ARIB_STD_B67:
            data = None
        else:
            logging.warning('Color transfer name not recognize! Use SRGB as default!')
            data = np.array([1.055, 0.0031308, 1.0 / 2.4, 12.92])

        return data, name, alias

    def __linear_de_linearize(self, x: Union(np.array, float)) -> Union(np.array, float):
        return x

    def __linear_linearize(self, x: Union(np.array, float)) -> Union(np.array, float):
        return x

    def __pq_de_linearize(self, x: Union(np.array, float)) -> Union(np.array, float):
        m1, m2, c1, c2, c3 = 0.1593017578125, 78.84375, 0.8359375, 18.8515625, 18.6875
        xp = np.power(x, m1)
        y = np.array((xp * c2 + c1) / (xp * c3 + 1), m2)
        return y

    def __pq_linearize(self, x: Union(np.array, float)) -> Union(np.array, float):
        m1, m2, c1, c2, c3 = 0.1593017578125, 78.84375, 0.8359375, 18.8515625, 18.6875
        xp = np.power(x, 1.0 / m2)
        y = np.power(np.max(xp - c1, 0) / (c2 - c3 * xp), 1.0 / m1)
        return y

    def __hlg_de_linearize(self, x: Union(np.array, float)) -> Union(np.array, float):
        a = 0.17883277
        b = 1 - 4 * a
        c = 0.5 - a * math.log(4 * a)
        y = np.piecewise(x, [x < 1/12, x >= 1/12],
                         [lambda x: np.sqrt(x * 3), lambda x: a * np.log(12 * x - b) + c])
        return y

    def __hlg_linearize(self, x: Union(np.array, float)) -> Union(np.array, float):
        a = 0.17883277
        b = 1 - 4 * a
        c = 0.5 - a * math.log(4 * a)
        y = np.piecewise(x, [x < 1/2, x >= 1/2],
                         [lambda x: np.power(x, 2) / 3, lambda x: (np.exp((x - c) / a) + b) / 12])
        return y

    def __init__(self, name) -> None:
        self.data, self.name, self.alias = ColorTransfer.get_data(name)
        if not self.data:
            if self.name == ColorTransfer.LINEAR:
                self.de_linearize = self.__linear_de_linearize
                self.linearize = self.__linear_linearize
            elif self.name == ColorTransfer.SMPTE2084:
                self.de_linearize = self.__pq_de_linearize
                self.linearize = self.__pq_linearize
            elif self.name == ColorTransfer.ARIB_STD_B67:
                self.de_linearize = self.__hlg_de_linearize
                self.linearize = self.__hlg_linearize

    def de_linearize(self, x: Union(np.array, float)) -> Union(np.array, float):
        alpha, beta, gamma, delta = self.data[0], self.data[1], self.data[2], self.data[3]
        y = np.piecewise(x, [np.abs(x) < beta, np.abs(x) >= beta],
                         [lambda x: delta * x,
                          lambda x: np.sign(x) * (alpha * np.power(np.abs(x), gamma) + alpha - 1.0)])
        return y

    def linearize(self, x: Union(np.array, float)) -> Union(np.array, float):
        alpha, beta, gamma, delta = self.data[0], self.data[1], self.data[2], self.data[3]
        y = np.piecewise(x, [np.abs(x) < beta, np.abs(x) >= beta],
                         [lambda x: x / delta,
                          lambda x: np.sign(x) * (np.power((np.abs(x) + alpha - 1.0) / alpha, 1.0 / gamma))])
        return y
