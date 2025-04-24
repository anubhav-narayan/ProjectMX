'''
MXALU11U

+-------+--------+-------------+---+-----+---+
| INSTR | OPCODE | DESCRIPTION | M | ~Cn | S |
+-------+--------+-------------+---+-----+---+
|  BUF  |    0   |       A     | 1 |  X  | F |
+-------+--------+-------------+---+-----+---+
|  NOT  |    1   |      ~A     | 1 |  X  | 0 |
+-------+--------+-------------+---+-----+---+
|  NAND |    2   |     A~&B    | 1 |  X  | 4 |
+-------+--------+-------------+---+-----+---+
|  XOR  |    3   |     A^B     | 1 |  X  | 6 |
+-------+--------+-------------+---+-----+---+
|  XNOR |    4   |     A~^B    | 1 |  X  | 9 |
+-------+--------+-------------+---+-----+---+
|  AND  |    5   |     A&B     | 1 |  X  | B |
+-------+--------+-------------+---+-----+---+
|   OR  |    6   |     A|B     | 1 |  X  | E |
+-------+--------+-------------+---+-----+---+
|  NOR  |    7   |     A~|B    | 1 |  X  | 1 |
+-------+--------+-------------+---+-----+---+
|  ADD  |    8   |     A+B     | 0 |  1  | 9 |
+-------+--------+-------------+---+-----+---+
|  ADC  |    9   |    A+B+1    | 0 |  0  | 9 |
+-------+--------+-------------+---+-----+---+
|  SUB  |    A   |     A-B     | 0 |  0  | 6 |
+-------+--------+-------------+---+-----+---+
|  SBB  |    B   |    A-B-1    | 0 |  1  | 6 |
+-------+--------+-------------+---+-----+---+
|  INCR |    C   |     A+1     | 0 |  0  | 0 |
+-------+--------+-------------+---+-----+---+
|  DECR |    D   |     A-1     | 0 |  1  | F |
+-------+--------+-------------+---+-----+---+
|   X2  |    E   |    A + A    | 0 |  1  | C |
+-------+--------+-------------+---+-----+---+
|  CLR  |    F   |      0      | 1 |  X  | 3 |
+-------+--------+-------------+---+-----+---+
'''

def MXALU11U(OPCODE: int, OPERAND1: int, OPERAND2: int):
    FLAGS = 0x00
    # OPCODE Reuse as Holder
    if OPCODE == 0x00:
        return (OPERAND1, FLAGS) 
    elif OPCODE == 0x01:
        if ~OPERAND1 == 0x00:
            FLAGS |= 0x01
        return (~OPERAND1, FLAGS)
    elif OPCODE == 0x02:
        OPCODE = ~(OPERAND1 & OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x03:
        OPCODE = OPERAND1 ^ OPERAND2
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x04:
        OPCODE = ~(OPERAND1 ^ OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x05:
        OPCODE = OPERAND1 & OPERAND2
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x06:
        OPCODE = OPERAND1 | OPERAND2
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x07:
        OPCODE = ~(OPERAND1 | OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x08:
        OPCODE = OPERAND1 + OPERAND2
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x09:
        OPCODE = OPERAND1 + OPERAND2 + 1
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0A:
        OPCODE = OPERAND1 - OPERAND2
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0B:
        OPCODE = OPERAND1 - OPERAND2 - 1
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0C:
        OPCODE = OPERAND1 + 1
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0D:
        OPCODE = OPERAND1 - 1
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0E:
        OPCODE = OPERAND1 + OPERAND1
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0F:
        OPCODE = 0x00
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
