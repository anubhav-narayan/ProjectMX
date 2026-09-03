import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import Timer
import os

class Test_SEU11:
    """
    Test class for the SEU11 ALU module.
    +--------+----------+-------------------------+--------------------------------+
    | Opcode | Mnemonic | Operation               | Flag Behavior (summary)        |
    +--------+----------+-------------------------+--------------------------------+
    |   0    | BUF      | f = a                   | Flags from result              |
    |   1    | CLR      | f = 0                   | Z=1, others cleared            |
    |   2    | NOT      | f = ~a                  | Flags from result              |
    |   3    | XOR      | f = a ^ b               | Flags from result              |
    |   4    | AND      | f = a & b               | Flags from result              |
    |   5    | OR       | f = a | b               | Flags from result              |
    |   6    | —        | (unused)                | —                              |
    |   7    | —        | (unused)                | —                              |
    |   8    | INCR     | f = a + 1               | Carry/Overflow from addition   |
    |   9    | DECR     | f = a - 1               | Carry/Overflow from subtraction|
    |   A    | ADD      | f = a + b               | Carry, Overflow set            |
    |   B    | ADC      | f = a + b + carry_in    | Carry, Overflow set            |
    |   C    | SUB      | f = a - b               | Carry=borrow, Overflow set     |
    |   D    | SBB      | f = a - b - carry_in    | Carry=borrow, Overflow set     |
    |   E    | CMP      | f = a - b (discarded)   | Flags only: Z/E/L/G updated    |
    |   F    | —        | (unused)                | —                              |
    +--------+----------+-------------------------+--------------------------------+
    """
    def __init__(self, dut):
        self.dut = dut
        self.m_rd_data = dut.m_rd_data
        self.a_rd_data = dut.a_rd_data
        self.m_wr_data = dut.m_wr_data
        self.a_wr_data = dut.a_wr_data
        self.ldi = dut.ldi
        self.imm8 = dut.imm8
        self.alu_ins = dut.alu_ins
        self.flags_in = dut.flags_in
        self.flags = dut.flags
        self.carry_in = dut.carry_in
        self.carry_out = dut.carry_out

    def setup(self):
        self.m_rd_data.value = 0
        self.a_rd_data.value = 0
        self.ldi.value = 0
        self.imm8.value = 0
        self.alu_ins.value = 0
        self.flags_in.value = 0
        self.carry_in.value = 0


async def test_buffer(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0x0 # Set opcode to BUF

    for x in range(0, 2**8):
        await Timer(2, 'ns')
        uut.m_rd_data.value = x
        await Timer(2, 'ns')
        res = int(uut.m_wr_data.value)
        assert res == (x & 0xFF)



async def test_clr(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0x1 # Set opcode to CLR

    for x in range(0, 2**8):
        await Timer(2, 'ns')
        uut.m_rd_data.value = x
        await Timer(2, 'ns')
        res = int(uut.m_wr_data.value)
        assert res == 0x00

async def test_not(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0x2 # Set opcode to NOT

    for x in range(0, 2**8):
        await Timer(2, 'ns')
        uut.m_rd_data.value = x
        await Timer(2, 'ns')
        res = int(uut.m_wr_data.value)
        assert res == (~x & 0xFF)


async def test_incr(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0x8 # Set opcode to INCR

    for x in range(0, 2**8):
        await Timer(2, 'ns')
        uut.m_rd_data.value = x
        await Timer(2, 'ns')
        res = int(uut.m_wr_data.value)
        assert res == ((x + 1) & 0xFF)


async def test_decr(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0x9 # Set opcode to DECR

    for x in range(0, 2**8):
        await Timer(2, 'ns')
        uut.m_rd_data.value = x
        await Timer(2, 'ns')
        res = int(uut.m_wr_data.value)
        assert res == ((x - 1) & 0xFF)


async def test_xor(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0x3 # Set opcode to XOR

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            await Timer(2, 'ns')
            uut.m_rd_data.value = x
            uut.a_rd_data.value = y
            await Timer(2, 'ns')
            res = int(uut.m_wr_data.value)
            assert res == ((x ^ y) & 0xFF)


async def test_and(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0x4 # Set opcode to AND

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            await Timer(2, 'ns')
            uut.m_rd_data.value = x
            uut.a_rd_data.value = y
            await Timer(2, 'ns')
            res = int(uut.m_wr_data.value)
            assert res == ((x & y) & 0xFF)


async def test_or(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0x5 # Set opcode to OR

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            await Timer(2, 'ns')
            uut.m_rd_data.value = x
            uut.a_rd_data.value = y
            await Timer(2, 'ns')
            res = int(uut.m_wr_data.value)
            assert res == ((x | y) & 0xFF)


async def test_add(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0xA # Set opcode to ADD

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            await Timer(2, 'ns')
            uut.m_rd_data.value = x
            uut.a_rd_data.value = y
            await Timer(2, 'ns')
            res = int(uut.m_wr_data.value)
            assert res == ((x + y) & 0xFF)
            assert uut.carry_out.value == ((x + y) >> 8) & 0x01


async def test_adc(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0xB # Set opcode to ADC

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            await Timer(2, 'ns')
            uut.m_rd_data.value = x
            uut.a_rd_data.value = y
            await Timer(2, 'ns')
            res = int(uut.m_wr_data.value)
            carry = int(uut.carry_in.value)
            assert res == ((x + y + carry) & 0xFF)
            assert uut.carry_out.value == ((x + y + carry) >> 8) & 0x01

    uut.carry_in.value = 1

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            await Timer(2, 'ns')
            uut.m_rd_data.value = x
            uut.a_rd_data.value = y
            await Timer(2, 'ns')
            res = int(uut.m_wr_data.value)
            carry = int(uut.carry_in.value)
            assert res == ((x + y + carry) & 0xFF)
            assert uut.carry_out.value == ((x + y + carry) >> 8) & 0x01


async def test_sub(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0xC # Set opcode to SUB

    for x in range(1, 2**8):
        for y in range(1, 2**8):
            await Timer(2, 'ns')
            uut.m_rd_data.value = x
            uut.a_rd_data.value = y
            await Timer(2, 'ns')
            res = int(uut.m_wr_data.value)
            assert res == ((x - y) & 0xFF)
            # assert uut.carry_out.value == ((x - y) >> 8) & 0x01


async def test_sbb(dut):
    uut = Test_SEU11(dut)
    uut.setup()
    uut.alu_ins.value = 0xD # Set opcode to SBB

    for x in range(1, 2**8):
        for y in range(1, 2**8):
            await Timer(2, 'ns')
            uut.m_rd_data.value = x
            uut.a_rd_data.value = y
            await Timer(2, 'ns')
            res = int(uut.m_wr_data.value)
            carry = int(uut.carry_in.value)
            assert res == ((x - y - carry) & 0xFF)
            # assert uut.carry_out.value == ((x - y - carry) >> 8) & 0x01

    uut.carry_in.value = 1

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            await Timer(2, 'ns')
            uut.m_rd_data.value = x
            uut.a_rd_data.value = y
            await Timer(2, 'ns')
            res = int(uut.m_wr_data.value)
            carry = int(uut.carry_in.value)
            assert res == ((x - y - carry) & 0xFF)
            # assert uut.carry_out.value == ((x - y - carry) >> 8) & 0x01


for x in [
            test_buffer,
            test_clr,
            test_not,
            test_incr,
            test_decr,
            test_xor,
            test_and,
            test_or,
            test_add,
            test_adc,
            test_sub,
            test_sbb,
            # test_x2,
        ]:
    factory = TestFactory(x)
    factory.generate_tests()
