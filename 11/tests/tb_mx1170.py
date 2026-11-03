import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer


class MX1170:
    HALT = 4

    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.clk
        self.rst = dut.rst
        self.nmi = dut.nmi
        self.irq = dut.irq

        self.ins_rd_txn_start = dut.ins_rd_txn_start
        self.ins_rd_data = dut.ins_rd_data
        self.ins_rd_ready = dut.ins_rd_ready
        self.ins_rd_addr = dut.ins_rd_addr
        self.ins_rd_txn_ack = dut.ins_rd_txn_ack
        self.ins_rd_txn_cpl = dut.ins_rd_txn_cpl

        self.data_rd_txn_start = dut.data_rd_txn_start
        self.data_rd_data = dut.data_rd_data
        self.data_rd_ready = dut.data_rd_ready
        self.data_rd_addr = dut.data_rd_addr
        self.data_rd_txn_ack = dut.data_rd_txn_ack
        self.data_rd_txn_cpl = dut.data_rd_txn_cpl

        self.data_wr_txn_start = dut.data_wr_txn_start
        self.data_wr_data = dut.data_wr_data
        self.data_wr_ready = dut.data_wr_ready
        self.data_wr_addr = dut.data_wr_addr
        self.data_wr_txn_ack = dut.data_wr_txn_ack
        self.data_wr_txn_cpl = dut.data_wr_txn_cpl

        self.instruction_memory = [0] * 256
        self.data_memory = [0] * 256
        self.instruction_transactions = []
        self._instruction_was_active = False
        self.write_transactions = []
        self._write_was_active = False

    def setup(self, program):
        self.instruction_memory[: len(program)] = program
        self.rst.value = 1
        self.nmi.value = 0
        self.irq.value = 0

        for ready in (
            self.ins_rd_ready,
            self.data_rd_ready,
            self.data_wr_ready,
        ):
            ready.value = 1

        for response in (
            self.ins_rd_txn_ack,
            self.ins_rd_txn_cpl,
            self.data_rd_txn_ack,
            self.data_rd_txn_cpl,
            self.data_wr_txn_ack,
            self.data_wr_txn_cpl,
        ):
            response.value = 0

    async def service_buses(self):
        while True:
            await FallingEdge(self.clk)

            ins_start = int(self.ins_rd_txn_start.value)
            ins_addr = int(self.ins_rd_addr.value)
            self.ins_rd_data.value = self.instruction_memory[ins_addr]
            if ins_start and not self._instruction_was_active:
                self.instruction_transactions.append(
                    (ins_addr, self.instruction_memory[ins_addr])
                )
            self._instruction_was_active = bool(ins_start)
            self.ins_rd_txn_ack.value = ins_start
            self.ins_rd_txn_cpl.value = ins_start

            data_rd_start = int(self.data_rd_txn_start.value)
            self.data_rd_data.value = self.data_memory[
                int(self.data_rd_addr.value)
            ]
            self.data_rd_txn_ack.value = data_rd_start
            self.data_rd_txn_cpl.value = data_rd_start

            data_wr_start = int(self.data_wr_txn_start.value)
            self.data_wr_txn_ack.value = data_wr_start
            self.data_wr_txn_cpl.value = data_wr_start
            if data_wr_start and not self._write_was_active:
                address = int(self.data_wr_addr.value)
                data = int(self.data_wr_data.value)
                self.data_memory[address] = data
                self.write_transactions.append((address, data))
            self._write_was_active = bool(data_wr_start)

    async def start(self):
        cocotb.start_soon(Clock(self.clk, 2, units="ns").start())
        cocotb.start_soon(self.service_buses())
        await Timer(10, "ns")
        self.rst.value = 0

    async def run_until_halt(self, cycle_limit=100):
        for _ in range(cycle_limit):
            await RisingEdge(self.clk)
            await Timer(1, "ns")
            if int(self.dut.mstate.value) == self.HALT:
                return
        raise AssertionError(
            f"CPU did not halt within {cycle_limit} cycles "
            f"(mstate={int(self.dut.mstate.value)}, "
            f"INSP={int(self.dut.insp_r.value)}, "
            f"insr={int(self.dut.insr.value)}, "
            f"registers=0x{int(self.dut.inst_mxregs11.regs.value):032x})"
        )

    def register_value(self, index):
        registers = int(self.dut.inst_mxregs11.regs.value)
        return (registers >> (8 * index)) & 0xFF

    def fetched_addresses(self):
        addresses = [address for address, _ in self.instruction_transactions]
        return [
            address
            for index, address in enumerate(addresses)
            if index == 0 or address != addresses[index - 1]
        ]


@cocotb.test()
async def test_instruction_execution_and_halt(dut):
    uut = MX1170(dut)
    uut.setup([0x00, 0x00, 0xFF])
    await uut.start()
    await uut.run_until_halt()

    assert uut.register_value(0x0) == 0
    assert uut.register_value(0x6) == 3
    assert uut.fetched_addresses() == [0, 1, 2]
    assert uut.write_transactions == []


@cocotb.test()
async def test_nmi_interrupt_sequence_and_resume(dut):
    uut = MX1170(dut)
    uut.setup([0x00, 0x00, 0xFF])
    uut.instruction_memory[0x80:0x82] = [0x00, 0xF7]
    await uut.start()

    while not uut.instruction_transactions:
        await RisingEdge(uut.clk)
        await Timer(1, "ns")

    uut.nmi.value = 1
    await RisingEdge(uut.clk)
    await Timer(1, "ns")
    uut.nmi.value = 0

    await uut.run_until_halt(cycle_limit=200)

    assert uut.fetched_addresses() == [0, 0x80, 0x81, 1, 2]
    assert uut.register_value(0x0) == 0
    assert uut.register_value(0x6) == 3
    assert uut.write_transactions == []


@cocotb.test()
async def test_irq_interrupt_sequence_and_resume(dut):
    uut = MX1170(dut)
    uut.setup([0x00, 0x00, 0xFF])
    uut.instruction_memory[0xC0:0xC2] = [0x00, 0xF7]
    await uut.start()

    for _ in range(50):
        await RisingEdge(uut.clk)
        await Timer(1, "ns")
        if int(dut.mstate.value) == 2:
            break
    else:
        raise AssertionError("CPU did not reach instruction execution")

    uut.irq.value = 1
    await RisingEdge(uut.clk)
    await Timer(1, "ns")
    uut.irq.value = 0

    await uut.run_until_halt(cycle_limit=200)

    assert uut.fetched_addresses() == [0, 0xC0, 0xC1, 1, 2]
    assert uut.register_value(0x0) == 0
    assert uut.register_value(0x6) == 3
    assert uut.write_transactions == []
