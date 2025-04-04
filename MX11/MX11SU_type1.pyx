'''
    MX11SU Type 1 Instruction Simulator 
'''
from .MXREGS import MX_REGS
from .MXALU11U import MX11_ALU
from time import sleep


class MX11SU_type_1():
    def __init__(self, clock: float):
        self.__clk_time__ = 1/clock
        self.__regs__ = MX_REGS(4)
        self.__alu__ = MX11_ALU


    def creg_decode(self, opcode):
        cdef unsigned char dst_f, src_a, src_b
        cdef unsigned char rom_alu_sel[16]
        rom_alu_sel[:] = [
            0x1, 0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x2, 0x2, 0x1, 0x2
        ]
        cdef unsigned short rom_alu[24]
        rom_alu[:] = [
            0x021, 0x010, 0x020, 0x030,
            0x330, 0x331, 0x332, 0x335,
            0x000, 0x001, 0x002, 0x003,
            0x300, 0x301, 0x302, 0x305,
            0x000, 0x101, 0x202, 0x303,
            0x404, 0x505, 0x606, 0x707
        ]
        ins_sel = rom_alu_sel[opcode & 0x0F]
        rom_sel = (ins_sel << 3) | ((opcode >> 4) & 0x7)
        creg_sel = rom_alu[rom_sel]
        dst_f = (creg_sel >> 8) & 0xF
        src_b = (creg_sel >> 4) & 0xF
        src_a = (creg_sel) & 0xF

        return (dst_f, src_b, src_a)

    def run(self, opcode):
        oper = opcode & 0x0F
        (dst_f, src_b, src_a) = self.creg_decode(opcode)
        print((dst_f, src_b, src_a))
        sleep(self.__clk_time__)
        cdef unsigned char b
        b = self.__regs__[src_b]
        print(b)
        cdef unsigned char a
        a = self.__regs__[src_a]
        print(a)
        cdef unsigned char f
        f, flags = self.__alu__(oper, a, b)
        self.__regs__[dst_f] = f
        self.__regs__[0x07] = flags & 0x3F

    @property
    def regs(self):
        cdef list labels = [
            "A", "X", "Y", "D",
            "DAR", "MBR", "INSP", "FLAGS",
            "SA", "SX", "SY", "SD",
            "R0", "R1", "R2", "R3"
        ]

        # Compute max label width for clean alignment
        max_label_len = max(len(label) for label in labels)
        line_width = max_label_len + 9  # label + spacing + box chars

        # Top of table
        result = " MX_REGS Register View \n"
        result += "+" + "-" * (line_width+2) + "+\n"
        result += "| {:<{width}} | {:>6} |\n".format("REG", "VAL", width=max_label_len)
        result += "+" + "-" * (line_width+2) + "+\n"

        # Register rows
        for i in range(16):
            label = labels[i]
            value = f"0x{self.__regs__[i]:02X}"
            result += "| {:<{width}} | {:>6} |\n".format(label, value, width=max_label_len)

        # Bottom of table
        result += "+" + "-" * (line_width+2) + "+\n"
        return result


        