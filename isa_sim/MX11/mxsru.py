'''
	MX Shift Rotate Unit
'''

def MXSRU(OPCODE: int, DATA: int, width: int = 8):
	MASK = (1 << width) - 1
	DATA = DATA & MASK
	SHIFT = OPCODE & 0x7
	if OPCODE & 0x10 == 0x10:
		# Right
		if OPCODE & 0x08 == 0x08:
			# Rotate
			return ((DATA >> SHIFT) | (DATA << (width - SHIFT))) & MASK
		else:
			return DATA >> SHIFT
	else:
		# Left
		if OPCODE & 0x08 == 0x08:
			# Rotate
			return ((DATA << SHIFT) | (DATA >> (width - SHIFT))) & MASK
		else:
			return DATA << SHIFT