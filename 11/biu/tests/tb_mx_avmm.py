from cocotb_bus.drivers.avalon import AvalonMemory
from cocotb.clock import Clock

class TB:
	def __init__(self, dut) -> None:
		self.dut = dut
		self.clock = Clock(dut.clk, 2, 'ns')
		self.mem = AvalonMemory(dut, name="m0", clock=dut.clk)
		