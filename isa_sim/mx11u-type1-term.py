#!/usr/bin/env python3
'''
    MX11 ALU Machine Terminal

    COMMANDS    Description
    STOP        Stop Execution
    RUN         Run the complete tape
    REGS        Check Flag Register/Show Flags
'''
from ctypes import *
from prompt_toolkit import PromptSession
from MX11.mxsm.mxsm import Assembler
from MX11.MX11SU_type1 import MX11SU_type_1

# STORE = dict([(x, 0x00) for x in range(0x100)])
proc=MX11SU_type_1(100000000)

def batch(call_queue: list):
    asm=Assembler(open('prod.tab.json').read())
    call_queue = '\n'.join(call_queue)
    asm.assemble(call_queue)
    ins = asm.ins
    for x in ins:
        proc.run(x)
        print(proc.regs)



def print_call_queue(call_queue):
    call : str = ''
    for x in range(len(call_queue)):
        call += f"0x{x:02X} :    {call_queue[x]}\n"
    print(call)


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
    elif COMM.upper() == "STORE":
        print_call_queue(call_queue)
        continue
    elif COMM.upper() == "RESET":
        call_queue = []
        n = 0
        continue
    elif COMM.upper() == "STOP":
        break
    elif COMM.upper() == "RUN":
        batch(call_queue)
        n = 0
        call_queue = []
        continue
    else:
        call_queue.append(COMM)
    n = n+1
    pass
