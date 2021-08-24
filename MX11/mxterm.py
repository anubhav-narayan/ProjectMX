#!/usr/bin/env python3

from MX11 import MX11
from prompt_toolkit import PromptSession
import re

cpu = MX11(3000)

re1 = r"^[\t ]*(?P<POINTER>[a-zA-Z_][a-zA-Z0-9_]{,31}\:)?(?P<OPCODE>[A-Za-z]{3,4})?[\t ]*(?P<OPERANDS>[\t ]*.*?\,?)?(?P<COMMENT>[ \t]*\;.*)?$"
reop1 = r"^(?P<OPERAND>(?P<OP_HEX>[\t ]*0x[0-9abcdefABCDEF]{1,2}[\t ]*\,?)|(?P<OP_OCT>[\t ]*0o[0-7]{1,3}\,?)|(?P<OP_BIN>[\t ]*0b[0-1]{8}[\t ]*\,?)|(?P<OP_DEC>[\t ]*[0-9]{1,3}[\t ]*\,?)|(?P<ADDRESS>[\t ]*\$[0-9abcdefABCDEF]{1,2}[\t ]*\,?)|(?P<OP_NAME>[\t ]*[a-zA-Z_][a-zA-Z0-9_]{,31}[\t ]*\,?)){1}$"
reop2 = r"^(?P<OPERAND1>(?P<OP_HEX1>[\t ]*0x[0-9abcdefABCDEF]{1,2}[\t ]*\,?)|(?P<OP_OCT1>[\t ]*0o[0-7]{1,3}\,?)|(?P<OP_BIN1>[\t ]*0b[0-1]{8}[\t ]*)|(?P<OP_DEC1>[\t ]*[0-9]{1,3}[\t ]*)|(?P<ADDRESS1>[\t ]*\$[0-9abcdefABCDEF]{1,2}[\t ]*)|(?P<OP_NAME1>[\t ]*[a-zA-Z_][a-zA-Z0-9_]{,31}[\t ]*))\,[\t ]*(?P<OPERAND2>(?P<OP_HEX2>[\t ]*0x[0-9abcdefABCDEF]{1,2}[\t ]*\,?)|(?P<OP_OCT2>[\t ]*0o[0-7]{1,3}\,?)|(?P<OP_BIN2>[\t ]*0b[0-1]{8}[\t ]*\,?)|(?P<OP_DEC2>[\t ]*[0-9]{1,3}[\t ]*\,?)|(?P<ADDRESS2>[\t ]*\$[0-9abcdefABCDEF]{1,2}[\t ]*\,?)|(?P<OP_NAME2>[\t ]*[a-zA-Z_][a-zA-Z0-9_]{,31}[\t ]*\,?))$"


def batch(call_queue:list):
	for n, COMM in call_queue:
		COMM=COMM.split()
		if len(COMM)<3:
			COMM.extend(['00']*(3-len(COMM)))
			pass
		for x in range(0,len(COMM)):
			if COMM[x].upper() in MOT.keys():
				COMM[x]=MOT[COMM[x].upper()]
				pass
			COMM[x]=int(COMM[x],16)
			pass
		RES, FLAGS = MX11_ALU(COMM[0],COMM[1],COMM[2])
		print(f"{n} :    {RES:02X}")

FLAGS = 0
n=0
COMMS = PromptSession()
insr_queue = []
data_queue = []
pointer_queue = []
while True:
	address_size = 0
	try:
		COMM = COMMS.prompt(message=f'{n:02X} :    ')
	except KeyboardInterrupt:
		continue
	except EOFError:
		break
	if not COMM:
		continue
	if COMM.upper() == "CFLR":
		print(f"F :     {FLAGS : 09b}")
		continue
		pass
	if COMM.upper() == "RESET":
		call_queue = []
		n = 0
		continue
	elif COMM == "STOP":
		break
		pass
	elif COMM.upper() == "RUN":
		# batch(call_queue)
		# n = 0
		# call_queue = []
		continue
		pass
	else:
		matches = re.match(re1, COMM)
		match_group = matches.groupdict()
		if match_group['OPERANDS'] != '':
			if ',' in match_group['OPERANDS']:
				operand = re.match(reop2, match_group['OPERANDS'])
				data_queue.extend([(x, operand[x]) for x in operand if x != None])
			else:
				operand = re.match(reop1, match_group['OPERANDS'])
				data_queue.extend(set([(x) for x in operand if x != None]))
			op_groups = {k:v for (k, v) in operand.groupdict().items() if v != None}
		else:
			op_groups = {}
		if len(op_groups)==0:
			address_size = 1
		elif len(op_groups)==2:
			address_size = 2
		elif len(op_groups)==4:
			address_size = 3
		match_group['ADDRESS'] = n
		print(match_group)
		print(op_groups)
		insr_queue.append(match_group['OPCODE'])
	n=n+address_size
	pass