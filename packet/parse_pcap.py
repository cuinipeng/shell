#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pcapy
fpcap = pcapy.open_offline("ssh.pcap")
print(dir(fpcap))
try:
    while True:
        pkt = fpcap.next()
        pkthdr = pkt[0]
        pktbody = pkt[1]
        print(pkthdr.getcaplen())
        print(len(pktbody))
        print(repr(pktbody))
except pcapy.PcapError as e:
    print(e.message)
