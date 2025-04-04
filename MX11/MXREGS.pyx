'''
    MX Register Bank
'''
from array import array

cdef class MX_REGS():
    cdef unsigned int size
    cdef unsigned int max_addr
    cdef object __regs__
    def __init__(self, size):
        self.size = size
        self.max_addr = 1 << size
        self.__regs__ = array('B', [0x00] * self.max_addr)

    def __getitem__(self, addr):
        addr = addr % self.max_addr
        return self.__regs__[addr]

    def __setitem__(self, addr, data):
        addr = addr % self.max_addr
        self.__regs__[addr] = data & 0xFF

    def __repr__(self):
        cdef unsigned int cols = 2 * self.size
        cdef unsigned int i
        output = ["Registers:\n"]
        for i in range(self.max_addr):
            if i % cols == 0:
                output.append(f"\n0x{i:02X}: ")
            output.append(f"{self.__regs__[i]:02X} ")
        return "".join(output)