'''
MX11 ALU with Unsigned Arithematic Logic 

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
  +-----------+---+---+---+---+
  |           | N | O | C | Z |
  +-----------+---+---+---+---+
'''

cpdef (unsigned char, unsigned char) MX11_ALU(unsigned char OPCODE, unsigned char OPERAND1, unsigned char OPERAND2):
    cdef unsigned char FLAGS = 0x00
    # OPCODE Reuse as Holder
    if OPCODE == 0x00:
        return (0x00, FLAGS) 
    elif OPCODE == 0x01:
        if ~OPERAND1 == 0x00:
            FLAGS |= 0x01
        return (~OPERAND1, FLAGS)
    elif OPCODE == 0x02:
        OPCODE = OPERAND1 + (0x01 if OPERAND2 == 0 else OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x03:
        OPCODE = OPERAND1 - (0x01 if OPERAND2 == 0 else OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x04:
        OPCODE = OPERAND1 & OPERAND2
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x05:
        OPCODE = ~(OPERAND1 & OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x06:
        OPCODE = (OPERAND1 | OPERAND2)
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
        OPCOde = (OPERAND1 ^ OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x09:
        OPCODE = ~(OPERAND1 ^ OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0A:
        OPCODE = (OPERAND1 + OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0B:
        OPCODE = OPERAND1 + (~OPERAND2 + 1)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0C:
        OPCODE = (OPERAND1 - OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0D:
        OPCODE = (OPERAND1 * OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0E:
        OPCODE = int(OPERAND1 / OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
    elif OPCODE == 0x0F:
        OPCODE = (OPERAND1 % OPERAND2)
        if OPCODE > 0xFF:
            FLAGS |= 0x06
        if OPCODE == 0x00:
            FLAGS |= 0x01
        if OPCODE > 0x7F:
            FLAGS |= 0x80
        return (OPCODE, FLAGS)
