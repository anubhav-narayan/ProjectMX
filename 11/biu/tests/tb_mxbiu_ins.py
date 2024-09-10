import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import Timer, RisingEdge, FallingEdge
import os


async def reset(dut):
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.setimmediatevalue(1)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.setimmediatevalue(0)


async def test_ins_fetch(dut):
    cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())
    await reset(dut)
    dut.ce_n.setimmediatevalue(0)
    for x in range(256):
        dut.insp.value = x
        await RisingEdge(dut.valid)
        await Timer(4, units="ns")


for x in [
            test_ins_fetch
        ]:
    factory = TestFactory(x)
    factory.generate_tests()
