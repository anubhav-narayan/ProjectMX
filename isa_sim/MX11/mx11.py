'''
    MX11SU Instruction Simulator 
'''
from .mxregs import MXREGS
from .mxalu11u import MXALU11U
from .mxsru import MXSRU
from time import sleep
from array import array


class MX11SU():
    def __init__(self, clock: float):
        self.__clk_time__ = 1/clock
        self.__regs__ = MXREGS(4)
        self.__alu__ = MXALU11U
        self.__shifter__ = MXSRU
        self.__imem__ = array('B', b'\x00' * 256)
        self.__dmem__ = array('B', b'\x00' * 256)
        self.insr = 0x00


    def fetch(self):
        insr = self.__imem__[self.__regs__[0x6]]
        f, _ = self.__alu__(0xC, self.__regs__[0x6], 0x00)
        sleep(self.__clk_time__)
        self.__regs__[0x6] = f
        sleep(2*self.__clk_time__)
        self.insr = insr

    def alu_decode(self, opcode: int):
        rom_alu_sel = [
            0x1, 0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x2, 0x2, 0x1, 0x2
        ]
        rom_alu = [
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
        dst_f = ((creg_sel >> 8) & 0xF)
        src_b = ((creg_sel >> 4) & 0xF)
        src_a = ((creg_sel) & 0xF)
        oper = opcode & 0xF
        return (dst_f, self.__regs__[src_b], self.__regs__[src_a], oper)

    def mov_decode(self, opcode: int):
        rom_mov = [
            0x100, 0x200, 0x700, 0x007,
            0x102, 0x201, 0x103, 0x203,
            0x00C, 0x10D, 0x20E, 0x30F,
            0xC00, 0xD01, 0x502, 0xF03,
            0x800, 0x901, 0xA02, 0xB03,
            0x008, 0x109, 0x20A, 0x30B,
            0xC04, 0xD05, 0xE06, 0xF07,
            0x40C, 0x50D, 0x60E, 0x70F
        ]
        mov_sel = rom_mov[opcode & 0x1F]
        dst_f = ((mov_sel >> 8) & 0xF)
        src_b = ((mov_sel >> 4) & 0xF)
        src_a = ((mov_sel) & 0xF)
        oper = 0x00
        return (dst_f, self.__regs__[src_b], self.__regs__[src_a], oper)

    def jmp_decode(self, opcode: int, flags: int):
        rom_jmp_f = [
            0b00,  # ZERO
            0b00,  # ZERO
            0b01,  # CARRY
            0b01,  # CARRY
            0b10,  # EQUAL
            0b10,  # EQUAL
            0b11,  # LT
            0b11   # LT
        ]
        rom_jmp = [
            0x6030, 0x6060, 0x6060, 0x6030,
            0x6030, 0x6060, 0x6060, 0x6030,
            0x6030, 0x6060, 0x6060, 0x6030,
            0x6030, 0x6060, 0x6060, 0x6030,
            0x6638, 0x6060, 0x6060, 0x6638,
            0x6638, 0x6060, 0x6060, 0x6638,
            0x6638, 0x6060, 0x6060, 0x6638,
            0x6638, 0x6060, 0x6060, 0x6638
        ]
        flag_sel = rom_jmp_f[opcode & 0x7]
        fval = ((flags & 0x3) >> flag_sel) & 0x1
        mov_sel = rom_jmp[(((opcode & 0xF) << 1) | fval)]
        dst_f = ((mov_sel >> 0xC) & 0xF)
        src_b = ((mov_sel >> 0x8) & 0xF)
        src_a = ((mov_sel >> 0x4) & 0xF)
        oper = ((mov_sel) & 0xF)
        return (dst_f, self.__regs__[src_b], self.__regs__[src_a], oper)

    def sr_decode(self, opcode: int):
        return (0, 0, self.__regs__[0x0], opcode)

    def ldi_decode(self, opcode: int):
        ldv = opcode & 0xF
        return (0, 0, ldv, 0)

    def spc_decode(self, opcode: int):
        if opcode & 0x0F == 0x00:
            return (0x4, 0x0, self.__regs__[0x0], 0x0)
        elif opcode & 0x0F == 0x01:
            return (0x0, 0x0, 0x0, 0x0)
        elif opcode & 0x0F == 0x0F:
            return (0x0, 0x0, 0x0, 0x0)

    def decode(self, opcode: int):
        if opcode & 0x80 == 0x80:
            if opcode & 0xF0 == 0x80 or opcode & 0xF0 == 0x90:
                return self.mov_decode(opcode)
            elif opcode & 0xF0 == 0xA0:
                return self.jmp_decode(opcode, self.__regs__[0x07])
            elif opcode & 0xF0 == 0xC0 or opcode & 0xF0 == 0xD0:
                return self.sr_decode(opcode)
            elif opcode & 0xF0 == 0xE0:
                return self.ldi_decode(opcode)
            elif opcode & 0xF0 == 0xF0:
                return self.spc_decode(opcode)
        else:
            return self.alu_decode(opcode)

    
    def dex(self, opcode: int):
        (dst_f, src_b, src_a, oper) = self.decode(opcode)
        if opcode & 0xF0 == 0xC0 or opcode & 0xF0 == 0xD0:
            f = self.__shifter__(opcode, src_a, 8)
            sleep(self.__clk_time__)
            self.__regs__[dst_f] = f
        else:
            f, flags = self.__alu__(oper, src_a, src_b)
            sleep(self.__clk_time__)
            self.__regs__[dst_f] = f
            if opcode & 0x0F in range(0x01, 0x10):
                self.__regs__[0x07] = flags & 0x3F

    def nmi(self):
        sleep(self.__clk_time__)
        self.__regs__[0x6] = 0x80

    @property
    def regs(self):
        labels = [
            "A", "X", "Y", "D",
            "DAR", "MBR", "INSP", "FLAGS",
            "SA", "SX", "SY", "SD",
            "R0", "R1", "R2", "R3"
        ]

        # Compute max label width for clean alignment
        max_label_len = max(len(label) for label in labels)
        line_width = max_label_len + 2

        # Top of table
        result  = "+" + "-" * (line_width) + "+" + "-" * 8 + "+\n"
        result += "| {:<{width}} | {:>6} |\n".format("REG", "VAL", width=max_label_len)
        result += "+" + "-" * (line_width) + "+" + "-" * 8 + "+\n"

        # Register rows
        for i in range(16):
            label = labels[i]
            value = f"0x{self.__regs__[i]:02X}"
            result += "| {:<{width}} | {:>6} |\n".format(label, value, width=max_label_len)

        # Bottom of table
        result += "+" + "-" * (line_width) + "+" + "-" * 8 + "+\n"
        return result


        