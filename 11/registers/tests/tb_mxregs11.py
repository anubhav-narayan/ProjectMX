import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import Timer, RisingEdge


class MXREGS_11():
    def __init__(self, dut):
        self.dut = dut
        self.m_rd_data = dut.m_rd_data
        self.a_rd_data = dut.a_rd_data
        self.m_rd_addr = dut.m_rd_addr
        self.a_rd_addr = dut.a_rd_addr
        self.m_wr_data = dut.m_wr_data
        self.a_wr_data = dut.a_wr_data
        self.m_wr_addr = dut.m_wr_addr
        self.a_wr_addr = dut.a_wr_addr
        self.m_wr_le = dut.m_wr_le
        self.a_wr_le = dut.a_wr_le
        self.nmi = dut.nmi
        self.irq = dut.irq
        self.clk = Clock(dut.clk, 2, 'ns')
        self.rst = dut.rst
        cocotb.start_soon(self.clk.start())

    def setup(self):
        self.m_rd_addr.value = 0
        self.a_rd_addr.value = 0
        self.m_wr_addr.value = 0
        self.m_wr_data.value = 0
        self.a_wr_addr.value = 0
        self.a_wr_data.value = 0
        self.m_wr_le.value = 0
        self.a_wr_le.value = 0
        self.rst.value = 0

    async def reset(self):
        self.rst.value = 1
        await Timer(10, 'ns')
        self.rst.value = 0

    async def read_main(self, addr:int) -> int:
        await RisingEdge(self.dut.clk)
        self.m_rd_addr.value = addr & 0x0F
        await RisingEdge(self.dut.clk)
        data = self.m_rd_data.value
        return int(data)

    async def read_aux(self, addr:int) -> int:
        await RisingEdge(self.dut.clk)
        self.a_rd_addr.value = addr & 0x0F
        await RisingEdge(self.dut.clk)
        data = self.a_rd_data.value
        return int(data)

    async def write_main(self, addr:int, data:int) -> None:
        await RisingEdge(self.dut.clk)
        self.m_wr_addr.value = addr & 0x0F
        self.m_wr_data.value = data & 0xFF
        self.m_wr_le.value = 1
        await RisingEdge(self.dut.clk)
        self.m_wr_le.value = 0

    async def write_aux(self, addr:int, data: int) -> None:
        await RisingEdge(self.dut.clk)
        self.a_wr_addr.value = addr & 0x0F
        self.a_wr_data.value = data & 0xFF
        self.a_wr_le.value = 1
        await RisingEdge(self.dut.clk)
        self.a_wr_le.value = 0

    async def write_both(self, main_addr:int, main_data:int, aux_addr:int, aux_data:int) -> None:
        await RisingEdge(self.dut.clk)
        self.m_wr_addr.value = main_addr & 0x0F
        self.m_wr_data.value = main_data & 0xFF
        self.a_wr_addr.value = aux_addr & 0x0F
        self.a_wr_data.value = aux_data & 0xFF
        self.m_wr_le.value = 1
        self.a_wr_le.value = 1
        await RisingEdge(self.dut.clk)
        self.m_wr_le.value = 0
        self.a_wr_le.value = 0


async def test_reset(dut):
    uut = MXREGS_11(dut)
    uut.setup()
    await uut.reset()
    await Timer(10, 'ns')

async def test_main(dut):
    from random import randint
    uut = MXREGS_11(dut)
    uut.setup()
    await uut.reset()
    addr = randint(0, 16)
    data = randint(0, 256)
    await uut.write_main(addr, data)
    reg = await uut.read_main(addr)
    assert reg == data

async def test_aux(dut):
    from random import randint
    uut = MXREGS_11(dut)
    uut.setup()
    await uut.reset()
    addr = randint(0, 16)
    data = randint(0, 256)
    await uut.write_aux(addr, data)
    reg = await uut.read_aux(addr)
    assert reg == data

async def test_write_conflict(dut):
    from random import randint
    uut = MXREGS_11(dut)
    uut.setup()
    await uut.reset()
    addr = randint(0, 16)
    main_data = randint(0, 256)
    aux_data = randint(0, 256)
    await uut.write_both(addr, main_data, addr, aux_data)
    reg_main = await uut.read_main(addr)
    assert reg_main == main_data

async def test_ctx_lock(dut):
    from random import randint
    uut = MXREGS_11(dut)
    uut.setup()
    await uut.reset()
    # Write to INSP
    await uut.write_main(0x6, 0x55)
    # Set CTXS flag in FLAGS register (0x7)
    await uut.write_main(0x7, 0x40)  # Set CTXS bit
    # Attempt to write to registers 8-15 (should be locked)
    for addr in range(8, 16):
        await uut.write_main(addr, 0xAA)
        reg = await uut.read_main(addr)
        assert reg != 0xAA, f"Register {addr} should be locked during CTXS, but got {reg:#04x}"
    # Attempt to write to registers 0-8 (should not be locked)
    for addr in range(0, 7):
        await uut.write_main(addr, 0xAA)
        reg = await uut.read_main(addr)
        assert reg == 0xAA, f"Register {addr} should not be locked during CTXS, but got {reg:#04x}"
    # Clear CTXS flag
    await uut.write_main(0x7, 0x00)  # Clear CTXS bit
    # Now writes to registers 8-15 should succeed
    for addr in range(8, 16):
        await uut.write_main(addr, 0xAA)
        reg = await uut.read_main(addr)
        assert reg == 0xAA, f"Register {addr} should be writable after CTXS cleared, but got {reg:#04x}"
    # Check that INSP register (0x6) is still 0x55
    insp_reg = await uut.read_main(0x6)
    assert insp_reg == 0x55, f"INSP register should retain its value, but got {insp_reg:#04x}"

async def test_nmi_irq(dut):
    from random import randint
    uut = MXREGS_11(dut)
    uut.setup()
    await uut.reset()
    await RisingEdge(dut.clk)
    # Trigger NMI
    uut.nmi.value = 1
    await RisingEdge(dut.clk)
    uut.nmi.value = 0
    await RisingEdge(dut.clk)
    flags_reg = await uut.read_main(0x7)
    assert (flags_reg & 0x80) != 0, f"NMI flag should be set in FLAGS register, but got {flags_reg:#04x}"
    
    # Clear FLAGS register for next test
    await uut.write_main(0x7, 0x00)

    # Trigger IRQ
    uut.irq.value = 1
    await RisingEdge(dut.clk)
    uut.irq.value = 0
    await RisingEdge(dut.clk)
    flags_reg = await uut.read_main(0x7)
    assert (flags_reg & 0x80) != 0, f"IRQ flag should be set in FLAGS register, but got {flags_reg:#04x}"

for x in [
            test_reset,
            test_main,
            test_aux,
            test_write_conflict,
            test_ctx_lock,
            test_nmi_irq
        ]:
    factory = TestFactory(x)
    factory.generate_tests()
