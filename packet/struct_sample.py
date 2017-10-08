#!/usr/bin/env python
# -*- coding: utf-8 -*-

import ctypes
import struct

# struct.pack(fmt, v1, v2, ...)
# struct.unpack(fmt, string)
# struct.calcsize(fmt)
# struct.pack_into, struct.unpack_from
#
# 格式符    C语言类型           Python类型          长度
# x         pad byte            no value            1
# c         char                string of length 1  1
# b         signed char         integer             1
# B         unsigned char       integer             1
# ?         _Bool               bool                1
# h         short               integer             2
# H         unsigned short      integer             2
# i         int                 integer             4
# I         unsigned int        integer             4
# l         long                integer             4
# L         unsigned long       long                4
# q         long long           long                8
# Q         unsigned long long  long                8
# f         float               float               4
# d         double              float               8
# s         char[]              string
# p         char[]              string
# P         void *              long
#
# 大端模式:
#   数据的低位保存在内存的高地址中,而数据的高位保存在内存的低地址中.
# 小端模式:
#   指数据的低位保存在内存的低地址中,而数据的高位保存在内存的高地址中.
# 网络字节序:
#   大端模式
# @: 默认的字节序
#
# Character     Byte order              Size        Alignment
# @             native                  native      native
# =             native                  standard    none
# <             little-endian           standard    none
# >             big-endian              standard    none
# !             network (= big-endian)  standard    none

# 转换后的str虽然是字符串类型,但相当于其他语言中的字节流(字节数组),可以在网络上传输.
# 格式符"i"表示转换为int,'ii'表示有两个int变量.
# 进行转换后的结果长度为8个字节(int类型占用4个字节,两个int为8个字),
# 可以看到输出的结果是乱码,因为结果是二进制数据,所以显示为乱码.
# 可以使用python的内置函数repr来获取可识别的字符串,
# 其中十六进制的0x00000014, 0x00001009分别表示20和400
def test_1():
    a = 20
    b = 400
    byte_stream = struct.pack("ii", a, b)
    print(len(byte_stream))
    print(repr(byte_stream))
    print(type(byte_stream))    # <type 'str'>


def test_2():
    print(struct.calcsize("ii"))


def test_3():
    buf = ctypes.create_string_buffer(12)
    print(repr(buf.raw))
    # 0 is offset
    struct.pack_into("iii", buf, 0, 1, 2, -1)
    print(repr(buf.raw))
    r = struct.unpack_from("iii", buf, 0)
    print(r)


def test_4():
    ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:56.0) Gecko/20100101 Firefox/56.0"
    buf = ctypes.create_string_buffer(len(ua))
    print(repr(buf.raw))
    struct.pack_into("{0}s".format(len(ua)), buf, 0, ua)
    print(repr(buf.raw))
    print(type(buf.raw))    # <type 'str'>
    ctypes.memset(buf, 0, buf._length_)


def test_5():
    class POINT(ctypes.Structure):
    # class POINT(ctypes.BigEndianStructure):
        _fields_ = [
            ("x", ctypes.c_int),
            ("y", ctypes.c_int)
        ]

    point = POINT(10, 20)
    print(point.x, point.y)

    point = POINT(y=30)
    print(point.x, point.y)


def main():
    test_5()


if __name__ == "__main__":
    main()
