#!/usr/bin/env python
# -*- coding: utf-8 -*-

from scapy.all import *

# Stacking layers
packet = Ether()/IP(dst="www.slashdot.org")/TCP()/"GET /index.html HTTP/1.0 \n\n"
print(repr(packet))
print(hexdump(packet))
