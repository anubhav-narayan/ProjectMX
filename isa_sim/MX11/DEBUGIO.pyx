'''
MX11 Serial Port
'''

from MXDEV import MXDEV


class DEBUG_IO(MXDEV):
    def __init__(self):
        self.MEM = [0x00 for x in range(0x100)]
