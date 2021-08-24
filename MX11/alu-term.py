#!/usr/bin/env python3
'''
    MX11 ALU Machine Terminal

    OPCODE  MNEMONIC    Description
    0x00    NOP         No Operation
    0x01    NOT         Not Gate
    0x02    INCR        A+1
    0x03    DECR        A-1
    0x04    AND         A AND B
    0x05    NAND        0x01<-0x04
    0x06    OR          A OR B
    0x07    NOR         0x01<-0x06
    0x08    XOR         A XOR B
    0x09    XNOR        0x01<-0x08
    0x0A    ADD         A + B
    0x0B    NAD         A + 0x01<-B + 0x01
    0x0C    SUB         A - B
    0x0D    MUL         A x B
    0x0E    DIV         A / B
    0x0F    MOD         A mod B

    FLAGS

    CODE    SET
    0x00    NO SET
    0x01    ZERO
    0x02    CARRY
    0x03    CARRY ZERO
    0x04    OVERFLOW
    0x05    OVERFLOW ZERO
    0x06    OVERFLOW CARRY
    0x07    OVERFLOW CARRY ZERO
    0x08    NEGATIVE
    0x09    NEGATIVE ZERO
    0x0A    NEGATIVE CARRY
    0x0B    NEGATIVE CARRY ZERO
    0x0C    NEGATIVE OVERFLOW
    0x0D    NEGATIVE OVERFLOW ZERO
    0x0E    NEGATIVE OVERFLOW CARRY
    0x0F    NEGATIVE OVERFLOW CARRY ZERO
    0xX0    RESERVED NO SET
    0xX1    RESERVED ZERO
    0xX2    RESERVED CARRY
    0xX3    RESERVED CARRY ZERO
    0xX4    RESERVED OVERFLOW
    0xX5    RESERVED OVERFLOW ZERO
    0xX6    RESERVED OVERFLOW CARRY
    0xX7    RESERVED OVERFLOW CARRY ZERO
    0xX8    RESERVED NEGATIVE
    0xX9    RESERVED NEGATIVE ZERO
    0xXA    RESERVED NEGATIVE CARRY
    0xXB    RESERVED NEGATIVE CARRY ZERO
    0xXC    RESERVED NEGATIVE OVERFLOW
    0xXD    RESERVED NEGATIVE OVERFLOW ZERO
    0xXE    RESERVED NEGATIVE OVERFLOW CARRY
    0xXF    RESERVED NEGATIVE OVERFLOW CARRY ZERO

    COMMANDS    Description
    STOP        Stop Execution
    CFLR        Check Flag Register/Show Flags
'''
from ctypes import *
from prompt_toolkit import PromptSession
from MX11_ALU import MX11_ALU

MOT = {
 'NOP': '00', 'NOT': '01', 'INCR': '02', 'DECR': '03',
 'AND': '04', 'NAND': '05', 'OR': '06', 'NOR': '07', 'XOR': '08', 'XNOR': '09',
 'ADD': '0A', 'NAD': '0B', 'SUB': '0C', 'MUL': '0D', 'DIV': '0E', 'MOD': '0F'
}
STORE = dict([(x, 0x00) for x in range(0x100)])


def batch(call_queue: list):
    for n, COMM in call_queue:
        COMM = COMM.split()
        if len(COMM) < 3:
            COMM.extend(['00']*(3-len(COMM)))
            pass
        for x in range(0, len(COMM)):
            if COMM[x].upper() in MOT.keys():
                COMM[x] = MOT[COMM[x].upper()]
                COMM[x] = int(COMM[x], 16)
            elif COMM[x].upper() == 'MOV':
                COMM[x] = 0x10
            elif COMM[x][0] == '&':
                COMM[x] = int(COMM[x][1:])
            elif COMM[x][0] == '*':
                COMM[x] = STORE[int(COMM[x][1:])]
            else:
                COMM[x] = int(COMM[x], 16)
        if COMM[0] == 0x10:
            STORE[COMM[1]] = COMM[2]
            RES = COMM[1]
        else:
            RES, _ = MX11_ALU(COMM[0], COMM[1], COMM[2])
        print(f"0x{n:02X} :    {RES:02X}")


FLAGS = 0
n = 0
COMMS = PromptSession()
call_queue = []
while True:
    try:
        COMM = COMMS.prompt(message=f'0x{n:02X} :    ')
    except KeyboardInterrupt:
        continue
    except EOFError:
        break
    if not COMM:
        continue
    elif COMM.upper() == "CFLR":
        print(f"F :     {FLAGS : 09b}")
        print(f"F :   0x{FLAGS : 02X}")
        continue
        pass
    elif COMM.upper() == "STORE":
        print(STORE)
        continue
    elif COMM.upper() == "RESET":
        call_queue = []
        n = 0
        continue
    elif COMM.upper() == "STOP":
        break
        pass
    elif COMM.upper() == "RUN":
        batch(call_queue)
        n = 0
        call_queue = []
        continue
        pass
    else:
        call_queue.append((n, COMM))
    n = n+1
    pass
