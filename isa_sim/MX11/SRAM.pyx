'''
256 Byte SRAM Module
'''

from MXDEV import MXDEV


class SRAM(MXDEV):
    def __init__(self):
        self.MEM = [0x00 for x in range(0x100)]

    def __setitem__(self, addr: int, data: int):
        addr %= 0xFF
        self.MEM[addr] = data

    def __getitem__(self, addr: int):
        addr %= 0xFF
        return self.MEM[addr]

    def __repr__(self):
        rstr = '     00 01 02 03 04 05 06 07\n'
        for x in range(0, len(self.MEM), 8):
            rstr += f'0x{x:02X} '
            for y in range(x, x+8):
                rstr += f'{self.MEM[y]:02X} '
            rstr += '\n'
        return rstr

    def __len__(self):
        return len(self.MEM)

    def __delitem__(self, addr:int):
        addr %= 0xFF
        self.MEM[addr] = 0x00

    def clear(self):
        return self.__init__()

    def copy(self):
        return self.MEM.copy()

    def __cmp__(self, dict_:MXDEV):
        return self.MEM.__cmp__(dict_)

    def __iter__(self):
        return iter(self.MEM)