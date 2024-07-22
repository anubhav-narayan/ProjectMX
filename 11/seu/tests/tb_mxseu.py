import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import Timer
import os


async def test_disable(dut):
	dut.ce_n.value = 1
	await Timer(1, units='ns')

async def test_fetch(dut):
	dut.ce_n.value = 0
	dut.fetch.value = 1
	await Timer(1, units='ns')

async def test_dex(dut):
	dut.ce_n.value = 0
	dut.fetch.value = 0
	for x in range(0x100):
		dut.insr.value = x
		await Timer(1, units='ns')

for x in [
            test_disable,
            test_fetch,
            test_dex
        ]:
    factory = TestFactory(x)
    factory.generate_tests()
