'''
Test ROM
'''
from MXDEV import MXDEV

class ROM(MXDEV):
    def __init__(self):
        self.MEM = {
            0x00: 0x00,
            0x01: 0x00,
            0x02: 0x00,
            0x03: 0x0A,
            0x04: 0x05,
            0x05: 0xFF
        }

    def __getitem__(self, addr: int):
        addr %= 0xFF
        return self.MEM[addr]