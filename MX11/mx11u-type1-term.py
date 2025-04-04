#!/usr/bin/env python3
'''
    MX11 ALU Machine Terminal

    COMMANDS    Description
    STOP        Stop Execution
    STEP        Check Step Result
    RUN         Run the complete tape
    REGS        Check Flag Register/Show Flags
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
