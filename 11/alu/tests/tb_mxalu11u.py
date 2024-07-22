import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import Timer
import os


async def test_buffer(dut):

    dut.opcode.value = 0x0
    dut.b.setimmediatevalue(0)
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        dut.cs_n.value = 0
        dut.a.value = x
        await Timer(1)
        dut.cs_n.value = 1
        await Timer(1)
        res = int(dut.f.value)
        assert res == (x & 0xFF)


async def test_not(dut):

    dut.opcode.value = 0x1
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        dut.cs_n.value = 0
        dut.a.value = x
        await Timer(1)
        dut.cs_n.value = 1
        await Timer(1)
        res = int(dut.f.value)
        assert res == (~x & 0xFF)


async def test_nand(dut):

    dut.opcode.value = 0x2
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            assert res == (~(x & y) & 0xFF)


async def test_xor(dut):

    dut.opcode.value = 0x3
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            assert res == ((x ^ y) & 0xFF)


async def test_xnor(dut):

    dut.opcode.value = 0x4
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            assert res == (~(x ^ y) & 0xFF)


async def test_and(dut):

    dut.opcode.value = 0x5
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            assert res == ((x & y) & 0xFF)


async def test_or(dut):

    dut.opcode.value = 0x6
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            assert res == ((x | y) & 0xFF)


async def test_nor(dut):

    dut.opcode.value = 0x7
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            assert res == (~(x | y) & 0xFF)


async def test_add(dut):

    dut.opcode.value = 0x8
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            carry = (int(dut.flags.value) & 0x02) >> 1
            assert res == ((x + y) & 0xFF)
            assert carry == ((x + y) >> 8) & 0x01


async def test_adc(dut):

    dut.opcode.value = 0x9
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            carry = (int(dut.flags.value) & 0x02) >> 1
            assert res == ((x + y + 1) & 0xFF)
            assert carry == ((x + y + 1) >> 8) & 0x01


async def test_sub(dut):

    dut.opcode.value = 0xA
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            # carry = int(dut.cn8_n.value)
            assert res == ((x - y) & 0xFF)
            # assert carry == ~((x - y) >> 8) & 0x01


async def test_sbb(dut):

    dut.opcode.value = 0xB
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        for y in range(0, 2**8):
            dut.cs_n.value = 0
            dut.a.value = x
            dut.b.value = y
            await Timer(1)
            dut.cs_n.value = 1
            await Timer(1)
            res = int(dut.f.value)
            # carry = int(dut.cn8_n.value)
            assert res == ((x - y - 1) & 0xFF)
            # assert carry == ~((x - y - 1) >> 8) & 0x01


async def test_incr(dut):

    dut.opcode.value = 0xC
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        dut.cs_n.value = 0
        dut.a.value = x
        await Timer(1)
        dut.cs_n.value = 1
        await Timer(1)
        res = int(dut.f.value)
        # carry = int(dut.cn8_n.value)
        assert res == ((x + 1) & 0xFF)
        # assert carry == ~((x - y) >> 8) & 0x01


async def test_decr(dut):

    dut.opcode.value = 0xD
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        dut.cs_n.value = 0
        dut.a.value = x
        await Timer(1)
        dut.cs_n.value = 1
        await Timer(1)
        res = int(dut.f.value)
        # carry = int(dut.cn8_n.value)
        assert res == ((x - 1) & 0xFF)
        # assert carry == ~((x - y) >> 8) & 0x01


async def test_x2(dut):

    dut.opcode.value = 0xE
    dut.b.setimmediatevalue(0)
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        dut.cs_n.value = 0
        dut.a.value = x
        await Timer(1)
        dut.cs_n.value = 1
        await Timer(1)
        res = int(dut.f.value)
        # carry = int(dut.cn8_n.value)
        assert res == ((x + x) & 0xFF)
        # assert carry == ~((x - y) >> 8) & 0x01


async def test_clr(dut):

    dut.opcode.value = 0xF
    dut.cs_n.setimmediatevalue(1)

    for x in range(0, 2**8):
        dut.cs_n.value = 0
        dut.a.value = x
        await Timer(1)
        dut.cs_n.value = 1
        await Timer(1)
        res = int(dut.f.value)
        # carry = int(dut.cn8_n.value)
        assert res == 0x00
        # assert carry == ~((x - y) >> 8) & 0x01


for x in [
            test_buffer,
            test_not,
            test_nand,
            test_xor,
            test_xnor,
            test_and,
            test_or,
            test_nor,
            test_add,
            test_adc,
            test_sub,
            test_sbb,
            test_incr,
            test_decr,
            test_x2,
            test_clr
        ]:
    factory = TestFactory(x)
    factory.generate_tests()
