import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer


class MX1171:
    HALT = 4
    SEU_ROM_FILE = os.path.join(
        os.path.dirname(__file__), "..", "alu11", "seu.hex"
    )

    def __init__(self, dut):
        self.dut = dut
        self.instruction_memory = [0] * 256
        self.data_memory = [0] * 256
        with open(self.SEU_ROM_FILE, encoding="ascii") as rom_file:
            self.microcode_memory = [
                int(line, 16) for line in rom_file
            ]
        if len(self.microcode_memory) != 256:
            raise AssertionError("SEU microcode ROM must contain 256 words")
        self.microcode_memory *= 4
        self.instruction_transactions = []
        self.data_read_transactions = []
        self.write_transactions = []
        self.microcode_transactions = []
        self._instruction_was_active = False
        self._write_was_active = False
        self._microcode_was_active = False

    def setup(self, program, data_zero=0):
        self.instruction_memory = [0] * 256
        self.instruction_memory[: len(program)] = program
        self.data_memory = [0] * 256
        self.data_memory[0] = data_zero

        self.dut.rst.value = 1
        self.dut.nmi.value = 0
        self.dut.irq.value = 0
        for ready in (
            self.dut.ins_rd_ready,
            self.dut.data_rd_ready,
            self.dut.data_wr_ready,
            self.dut.microcode_rd_ready,
        ):
            ready.value = 1
        for response in (
            self.dut.ins_rd_txn_ack,
            self.dut.ins_rd_txn_cpl,
            self.dut.data_rd_txn_ack,
            self.dut.data_rd_txn_cpl,
            self.dut.data_wr_txn_ack,
            self.dut.data_wr_txn_cpl,
            self.dut.microcode_rd_txn_ack,
            self.dut.microcode_rd_txn_cpl,
        ):
            response.value = 0

        self.instruction_transactions.clear()
        self.data_read_transactions.clear()
        self.write_transactions.clear()
        self.microcode_transactions.clear()
        self._instruction_was_active = False
        self._write_was_active = False
        self._microcode_was_active = False

    async def service_buses(self):
        while True:
            await FallingEdge(self.dut.clk)

            ins_start = int(self.dut.ins_rd_txn_start.value)
            ins_addr = int(self.dut.ins_rd_addr.value)
            self.dut.ins_rd_data.value = self.instruction_memory[ins_addr]
            if ins_start and not self._instruction_was_active:
                self.instruction_transactions.append(ins_addr)
            self._instruction_was_active = bool(ins_start)
            self.dut.ins_rd_txn_ack.value = ins_start
            self.dut.ins_rd_txn_cpl.value = ins_start

            data_rd_start = int(self.dut.data_rd_txn_start.value)
            data_rd_addr = int(self.dut.data_rd_addr.value)
            self.dut.data_rd_data.value = self.data_memory[data_rd_addr]
            if data_rd_start:
                self.data_read_transactions.append(data_rd_addr)
            self.dut.data_rd_txn_ack.value = data_rd_start
            self.dut.data_rd_txn_cpl.value = data_rd_start

            data_wr_start = int(self.dut.data_wr_txn_start.value)
            self.dut.data_wr_txn_ack.value = data_wr_start
            self.dut.data_wr_txn_cpl.value = data_wr_start
            if data_wr_start and not self._write_was_active:
                address = int(self.dut.data_wr_addr.value)
                data = int(self.dut.data_wr_data.value)
                self.data_memory[address] = data
                self.write_transactions.append((address, data))
            self._write_was_active = bool(data_wr_start)

            microcode_start = int(self.dut.microcode_rd_txn_start.value)
            microcode_addr = int(self.dut.microcode_rd_addr.value)
            self.dut.microcode_rd_data.value = self.microcode_memory[
                microcode_addr
            ]
            if microcode_start and not self._microcode_was_active:
                self.microcode_transactions.append(microcode_addr)
            self._microcode_was_active = bool(microcode_start)
            self.dut.microcode_rd_txn_ack.value = microcode_start
            self.dut.microcode_rd_txn_cpl.value = microcode_start

    async def start(self):
        cocotb.start_soon(Clock(self.dut.clk, 2, units="ns").start())
        cocotb.start_soon(self.service_buses())
        await Timer(10, "ns")
        self.dut.rst.value = 0

    async def run_until_halt(self, cycle_limit=1000):
        for _ in range(cycle_limit):
            await RisingEdge(self.dut.clk)
            await Timer(1, "ns")
            if int(self.dut.mstate.value) == self.HALT:
                return
        raise AssertionError(f"CPU did not halt within {cycle_limit} cycles")

    def register_value(self, index):
        registers = int(self.dut.inst_mxregs11.regs.value)
        return (registers >> (8 * index)) & 0xFF

    def set_register_values(self, values):
        registers_signal = self.dut.inst_mxregs11.regs
        registers = int(registers_signal.value)
        for index, value in values.items():
            mask = 0xFF << (8 * index)
            registers = (registers & ~mask) | ((value & 0xFF) << (8 * index))
        registers_signal.value = registers


@cocotb.test()
async def test_instruction_execution_and_halt(dut):
    uut = MX1171(dut)
    uut.setup([0xFF])
    await uut.start()
    await uut.run_until_halt()

    assert 0 in uut.instruction_transactions
    assert uut.register_value(0x6) == 1
    assert uut.write_transactions == []
    assert uut.microcode_transactions == []


@cocotb.test()
async def test_interrupt_vector_and_return_sequence(dut):
    uut = MX1171(dut)
    uut.setup([0x00, 0x00, 0xFF])
    uut.instruction_memory[0x80:0x82] = [0x00, 0xF7]
    await uut.start()

    for _ in range(50):
        await RisingEdge(dut.clk)
        await Timer(1, "ns")
        if uut.instruction_transactions:
            break
    else:
        raise AssertionError("CPU did not begin instruction fetch")

    uut.dut.nmi.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, "ns")
    uut.dut.nmi.value = 0
    await uut.run_until_halt(cycle_limit=200)

    fetch_sequence = []
    for address in uut.instruction_transactions:
        if address in (0, 1, 2, 0x80, 0x81) and (
            not fetch_sequence or fetch_sequence[-1] != address
        ):
            fetch_sequence.append(address)
    assert fetch_sequence == [0, 0x80, 0x81, 1, 2]
    assert uut.register_value(0x6) == 3
    assert uut.write_transactions == []
    assert uut.microcode_transactions == []


@cocotb.test()
async def test_dar_00_selects_seu(dut):
    await run_dar_case(dut, 0)


@cocotb.test()
async def test_dar_01_selects_shifter(dut):
    await run_dar_case(dut, 1)


@cocotb.test()
async def test_dar_02_selects_page_controller(dut):
    await run_dar_case(dut, 2)


@cocotb.test()
async def test_dar_02_page_controller_sets_irq_page(dut):
    uut = MX1171(dut)
    uut.setup([0x21, 0xFF])
    await uut.start()
    uut.set_register_values({0x1: 0x5A, 0x5: 2})
    await Timer(1, "ns")
    assert uut.register_value(0x1) == 0x5A
    await uut.run_until_halt()

    assert int(dut.inst_page_ctrl.irqpage_r.value) == 0x5A
    assert int(dut.ins_page_addr.value) == 0
    uut.dut.irq.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, "ns")
    assert int(dut.ins_page_addr.value) == 0x5A, (
        f"IRQ page not selected: page={int(dut.ins_page_addr.value):02x}, "
        f"irq_r={int(dut.irq_r.value)}, "
        f"stored={int(dut.inst_page_ctrl.irqpage_r.value):02x}"
    )
    uut.dut.irq.value = 0


@cocotb.test()
async def test_dar_03_selects_no_extension(dut):
    await run_dar_case(dut, 3)


@cocotb.test()
async def test_dar_04_loads_profile_zero(dut):
    await run_dar_case(dut, 4)


@cocotb.test()
async def test_dar_05_loads_profile_one(dut):
    await run_dar_case(dut, 5)


@cocotb.test()
async def test_dar_06_loads_profile_two(dut):
    await run_dar_case(dut, 6)


@cocotb.test()
async def test_dar_07_loads_profile_three(dut):
    await run_dar_case(dut, 7)


async def run_dar_case(dut, dar):
    uut = MX1171(dut)
    uut.setup([0x01, 0xFF])
    await uut.start()
    uut.set_register_values({0x0: 1, 0x5: dar})
    await uut.run_until_halt(cycle_limit=3000)

    expected_a = {
        0: 0,
        1: 2,
        2: 1,
        3: 1,
        4: 0,
        5: 0,
        6: 0,
        7: 0,
    }
    assert uut.register_value(0x0) == expected_a[dar]
    assert uut.register_value(0x5) == dar
    assert 0 in uut.instruction_transactions
    assert 1 in uut.instruction_transactions
    assert uut.write_transactions == []

    if 4 <= dar <= 7:
        profile_base = (dar - 4) * 256
        assert len(uut.microcode_transactions) == 256
        assert set(uut.microcode_transactions) == set(
            range(profile_base, profile_base + 256)
        )
        assert int(dut.microcode_locked_profile.value) == dar - 4
    else:
        assert uut.microcode_transactions == []

    if dar == 2:
        assert int(dut.ins_page_addr.value) == 0
        assert int(dut.data_page_addr.value) == 0
