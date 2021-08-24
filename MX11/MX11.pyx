'''
The Control Unit with Registers of the MX11 Processor
Von Neumann Style Computer

  Instruction Format

  +--------+------+------+
  | OPCODE |  A/V |  A/V |
  +--------+------+------+
  | 2 Hex  | 2 Hex| 2 Hex|
  |     2 Byte    |      |

  OPCODE Format

  +---+---------+-------------------+
  | E |    IC   |       OPCODE      |
  +---+---------+-------------------+

  E - ALU Enable Active Low
  IC - Instruction Class

+-------------+---------------------------------------------------------------------------------------------------------------+
| INSTRUCTION |                                                  OPCODE CLASS                                                 |
|    CLASS    +------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|             | 0x00 | 0x01 | 0x02 | 0x03 | 0x04 | 0x05 | 0x06 | 0x07 | 0x08 | 0x09 | 0x0A | 0x0B | 0x0C | 0x0D | 0x0E | 0x0F |
+-----+-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|  IL |  0x00 | #NOP |  NOT | INCR | DECR |  AND | NAND |  OR  |  NOR |  XOR | XNOR |  ADD |  NAD |  SUB |  MUL |  DIV |  MOD |
|     +-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|     |  0x80 |      |  LDA |  LDB |  INT |      |  MOV |  SHR |  SHL | SDEV |      |      |      |      | PUSH |      |  LPC |
+-----+-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|  RL |  0x10 |      |      | INCR | DECR |  AND | NAND |  OR  |  NOR |  XOR | XNOR |  ADD |  NAD |  SUB |  MUL |  DIV |  MOD |
|     +-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|     |  0x90 |      |      |      |      |      |  MOV |  SHR |  SHL |      |      |  CMP |      |      |      |      |      |
+-----+-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|  IR |  0x20 |      |  NOT | INCR | DECR |  AND | NAND |  OR  |  NOR |  XOR | XNOR |  ADD |  NAD |  SUB |  MUL |  DIV |  MOD |
|     +-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|     |  0xA0 |      |  LDA |  LDB |      |      |      |  SHR |  SHL | SDEV |      |      |      |      | PUSH |  POP |  LPC |
+-----+-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|  RA |  0x30 |      |      |      |      |      |      |      |      |      |      |      |      |      |  MAC |      |      |
|     +-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|     |  0xB0 |      |      |      |      |      |  MOV |      |      |      |      |      |      |      |      |      |      |
+-----+-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|  IA |  0x40 |      |      |      |      |      |      |      |      |      |      |      |      |      |  MAC |      |      |
|     +-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|     |  0xC0 |      |  LDA |  LDB |  LCH |      |      |      |      |  JMP |  JNZ |      |  BRC |  BNZ |      |      |  LPC |
+-----+-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|  AR |  0x50 |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |
|     +-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|     |  0xD0 |      |      |      |      |      |  MOV |      |      |      |      |      |      |      |      |      |      |
+-----+-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|  RR |  0x60 |      |      | INCR | DECR |  AND | NAND |  OR  |  NOR |  XOR | XNOR |  ADD |  NAD |  SUB |  MUL |  DIV |  MOD |
|     +-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|     |  0xE0 |      |      |      |      | XCHG |  MOV |  SHR |  SHL |      |      |  CMP |      |      |      |      |      |
+-----+-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|  SL |  0x70 |  NOP |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |
|     +-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+
|     |  0xF0 |  LFA |      |      |  INT |      |      |      |      | VMEM |      |      |      |      | RSET |  POP | HALT |
+-----+-------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+

# - Hardwired Control

  REGSITERS
  A - Accumulator
  B - Base Pointer
  R[0-11] - General
  SP - Stack Pointer
  SR - Status Register

  Addressing Modes        MODE        OPCODE MASK
  Implicit, Literal       0b000       0x00
  Implicit, Register      0b010       0x20
  Implicit, Address       0b100       0x40
  Register, Register      0b110       0x60
  Register, Literal       0b001       0x10
  Register, Address       0b011       0x30
  Address, Register       0b101       0x50
  Single Byte             0b111       0x70

  REG CODE        Register
  0x00            A
  0x01            SP
  0x02            B
  0x03            SR
  0x0[4-F]        R[0-11]

  FLAGS
  +---+---+---+---+---+---+---+
  |   | V | I | N | O | C | Z |
  +---+---+---+---+---+---+---+
'''

from time import sleep
from CACHE import CACHE
from MX11_ALU import MX11_ALU
from MXDEV import MXDEV


class MX11():
    def __init__(self, clock: float):
        self.__CLK_TIME = 1/clock
        self.REG_BANK = dict([(x, 0x00) for x in range(0x10)])
        self.EX_REG = {0x00: 0x00, 0x01: 0x00, 0x02: 0x00}
        self.REG_BANK[0x01] = 0xF0
        self.REG_BANK[0x03] = 0x01
        self.__ALU = MX11_ALU
        self.__FLAGS = 0x00
        self.__INSP = 0x00
        self.__INSR = 0x00
        self.__PC = 0x00
        self.__MAR = 0x00
        self.__DAR = 0x00
        self.__MBR = 0x00
        self.__VDBA_BUS = dict([(x, MXDEV()) for x in range(0x100)])

    @property
    def state(self):
        rstr = 'MX11 vCPU\n'
        rstr += f'A : 0x{self.REG_BANK[0x00]:02X} B : 0x{self.REG_BANK[0x02]:02X}\n'
        rstr += f'SP : 0x{self.REG_BANK[0x01]:02X} SR : 0x{self.REG_BANK[0x03]:02X}\n'
        rstr += f'INSP : 0x{self.__INSP:02X} INSR : 0x{self.__INSR:02X}\n'
        rstr += f'DAR : 0x{self.__DAR:02X} MAR : 0x{self.__MAR:02X} MBR : 0x{self.__MBR:02X}\n'
        rstr += f'EXR0: 0x{self.EX_REG[0x00]:02X} EXR1: {self.EX_REG[0x01]:02X}\n'
        for x in range(0, 12, 4):
            rstr += f'R{x:02}: 0x{self.REG_BANK[0x04+x]:02x}'\
                 + f' R{x+1:02}: 0x{self.REG_BANK[0x05+x]:02x}'\
                 + f' R{x+2:02}: 0x{self.REG_BANK[0x06+x]:02x}'\
                 + f' R{x+3:02}: 0x{self.REG_BANK[0x07+x]:02x}\n'
        return rstr

    def add_device(self, device: MXDEV, address: int):
        self.__VDBA_BUS[address] = device

    def fetch(self):
        try:
            if self.REG_BANK[0x03] == 0x00: # Cache Fetch Cycle 0x00
                return
            if self.REG_BANK[0x03] == 0x01: # Simple Fetch Cycle 0x01
                self.__MAR = self.__INSP
                self.__INSR = self.__VDBA_BUS[self.__DAR][self.__MAR]
                self.__MAR = self.__ALU(0x02, self.__MAR, 0x01)
                self.REG_BANK[0x03] = 0x04
                return
            elif self.REG_BANK[0x03] in (0x02, 0x03): # Data Fetch Cycle 0x02, 0x03
                self.__MBR = self.__VDBA_BUS[self.__DAR][self.__MAR]
                self.__MAR = self.__ALU(0x02, self.__MAR, 0x01)
                self.REG_BANK[0x03] += 0x01
                return
        except Exception:
            self.REG_BANK[0x03] = 0xF0

    def decode(self):
        try:
            if self.REG_BANK[0x03] == 0x04:
                if self.__INSR & 0x70 == 0x70:
                    self.REG_BANK[0x03] = 0x05
                    self.__INSP = self.__ALU(0x02, self.__INSP, 0x01)
                    return
                elif self.__INSR & 0x50 == 0x50:
                    self.REG_BANK[0x03] = 0x01
                    self.__INSP = self.__ALU(0x02, self.__INSP, 0x03)
                    return
                elif self.__INSR & 0x30 == 0x30:
                    self.REG_BANK[0x03] = 0x01
                    self.__INSP = self.__ALU(0x02, self.__INSP, 0x03)
                    return
                elif self.__INSR & 0x10 == 0x10:
                    self.REG_BANK[0x03] = 0x01
                    self.__INSP = self.__ALU(0x02, self.__INSP, 0x03)
                    return
                elif self.__INSR & 0x60 == 0x60:
                    self.REG_BANK[0x03] = 0x02
                    self.__INSP = self.__ALU(0x02, self.__INSP, 0x02)
                    self.EX_REG[0x00] = self.__MBR
                    return
                elif self.__INSR & 0x40 == 0x40:
                    self.REG_BANK[0x03] = 0x02
                    self.__INSP = self.__ALU(0x02, self.__INSP, 0x02)
                    self.EX_REG[0x00] = self.__MBR
                    return
                elif self.__INSR & 0x20 == 0x20:
                    self.REG_BANK[0x03] = 0x02
                    self.__INSP = self.__ALU(0x02, self.__INSP, 0x02)
                    self.EX_REG[0x00] = self.__MBR
                    return
                elif self.__INSR == 0x00:
                    self.REG_BANK[0x03] = 0x05
                    self.__INSP = self.__ALU(0x02, self.__INSP, 0x01)
                    return
                else:
                    self.REG_BANK[0x03] = 0x02
                    self.EX_REG[0x00] = self.__MBR
                    self.__INSP = self.__ALU(0x02, self.__INSP, 0x02)
                    return
            elif self.REG_BANK[0x03] == 0x03:
                self.REG_BANK[0x03] = 0x05
                return
        except Exception:
            self.REG_BANK[0x03] = 0xF1

    def execute(self):
        try:
            if self.REG_BANK[0x03] == 0x05:
                if self.__INSR & 0x80 == 0x80:
                    if self.__INSR & 0x70 == 0x70:
                        pass
                    if self.__INSR & 0x60 == 0x60:
                        pass
                    if self.__INSR & 0x50 == 0x50:
                        pass
                    if self.__INSR & 0x40 == 0x40:
                        pass
                    if self.__INSR & 0x30 == 0x30:
                        pass
                    if self.__INSR & 0x20 == 0x20:
                        pass
                    if self.__INSR & 0x10 == 0x10:
                        pass
                    else:
                        pass
                    self.REG_BANK[0x03] = 0x01
                    return
                else:
                    if self.__INSR & 0x70 == 0x70:
                        pass
                    if self.__INSR & 0x60 == 0x60:
                        pass
                    if self.__INSR & 0x50 == 0x50:
                        pass
                    if self.__INSR & 0x40 == 0x40:
                        pass
                    if self.__INSR & 0x30 == 0x30:
                        pass
                    if self.__INSR & 0x20 == 0x20:
                        pass
                    if self.__INSR & 0x10 == 0x10:
                        pass
                    else:
                        self.REG_BANK[0x00] = self.__ALU(
                            self.__INSR,
                            self.REG_BANK[0x00],
                            self.__MBR
                        )
                        self.__PC += 0x01
                        self.__PC &= 0xFF
                        pass
                    self.REG_BANK[0x03] = 0x01
                    return
        except Exception:
            self.REG_BANK[0x03] = 0xF2

    def read_cache(self):
        return self.__L1

    def write_cache(self, page:dict):
        for x in page:
            self.__L1[x] = page[x]

    def run(self):
        while self.__INSR != 0xFF:
            sleep(self.__CLK_TIME/3)
            self.fetch()
            sleep(self.__CLK_TIME/3)
            self.decode()
            sleep(self.__CLK_TIME/3)
            self.execute()

    def start(self):
        from threading import Thread
        self.running_cpu = Thread(target=self.run)
        self.running_cpu.daemon = True
        self.running_cpu.setName("MX11 vCPU")
        self.running_cpu.start()

    def stop(self):
        self.__INSR = 0xFF
        self.running_cpu.join()

    def reset(self):
        self.REG_BANK[0x01] = 0xF0
        self.REG_BANK[0x03] = 0x01
        self.__ALU = MX11_ALU
        self.__FLAGS = 0x00
        self.__INSP = 0x00
        self.__INSR = 0x00
        self.__PC = 0x00
        self.__MAR = 0x00
        self.__DAR = 0x00
        self.__MBR = 0x00

    def debug(self):
        UP = '\x1B[9A'
        CLR = '\x1B[0K'
        while 1:
            try:
                print(f'{self.state}{UP}', end='\r')
            except KeyboardInterrupt:
                print(f'{CLR}', end='')
                break
            except EOFError:
                print(f'{CLR}', end='')
                break

    def set_clock(self, clk: float = 0.00):
        if clk != 0.00:
            self.__CLK_TIME = 1/clk
        else:
            from psutil import cpu_freq
            self.__CLK_TIME = 10/cpu_freq().current
