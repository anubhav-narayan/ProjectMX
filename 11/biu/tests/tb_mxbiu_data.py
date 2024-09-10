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


async def test_row(dut):
    cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())
    await reset(dut)
    dut.mar.value = 0x00
    dut.mbr_in.value = 0xFE
    dut.store.value = 1
    await RisingEdge(dut.store_valid)
    await Timer(2, units="ns")
    dut.load.value = 1
    await RisingEdge(dut.load_valid)
    await Timer(2, units="ns")



for x in [
            test_row
        ]:
    factory = TestFactory(x)
    factory.generate_tests()
