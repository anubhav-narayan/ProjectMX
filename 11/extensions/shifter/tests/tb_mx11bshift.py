import cocotb
from cocotb.regression import TestFactory
from cocotb.triggers import Timer


class MX11BShift:
    def __init__(self, dut):
        self.dut = dut
        self.m_rd_addr = dut.m_rd_addr
        self.m_rd_data = dut.m_rd_data
        self.m_wr_addr = dut.m_wr_addr
        self.m_wr_data = dut.m_wr_data
        self.m_wr_le = dut.m_wr_le
        self.opcode = dut.opcode
        self.bs_ce = dut.bs_ce

    def setup(self):
        self.m_rd_data.value = 0
        self.opcode.value = 0
        self.bs_ce.value = 1


def expected_result(operation, value, amount):
    if operation in ("SHL", "ASL"):
        return (value << amount) & 0xFF
    if operation == "ROL":
        return ((value << amount) | (value >> (8 - amount))) & 0xFF
    if operation == "SHR":
        return value >> amount
    if operation == "ROR":
        return ((value >> amount) | (value << (8 - amount))) & 0xFF
    if operation == "ASR":
        signed_value = value if value < 0x80 else value - 0x100
        return (signed_value >> amount) & 0xFF
    raise ValueError(f"Unsupported shift operation: {operation}")


async def test_shift_mode(dut, mode):
    uut = MX11BShift(dut)
    uut.setup()
    opcode_base, operation = mode

    for amount in range(8):
        for value in range(256):
            uut.opcode.value = opcode_base | amount
            uut.m_rd_data.value = value
            await Timer(2, "ns")

            result = int(uut.m_wr_data.value)
            expected = expected_result(operation, value, amount)
            assert result == expected, (
                f"{operation} opcode={opcode_base | amount:#04x} "
                f"value={value:#04x}: got {result:#04x}, expected {expected:#04x}"
            )
            assert int(uut.m_wr_le.value) == 1
            assert int(uut.m_rd_addr.value) == 0
            assert int(uut.m_wr_addr.value) == 0


@cocotb.test()
async def test_disabled_shifter(dut):
    uut = MX11BShift(dut)
    uut.setup()
    uut.bs_ce.value = 0
    uut.opcode.value = 0x33
    uut.m_rd_data.value = 0x80
    await Timer(2, "ns")

    assert int(uut.m_wr_data.value) == 0x80
    assert int(uut.m_wr_le.value) == 0


factory = TestFactory(test_shift_mode)
factory.add_option(
    "mode",
    [
        (0x00, "SHL"),
        (0x08, "ROL"),
        (0x10, "SHR"),
        (0x18, "ROR"),
        (0x20, "ASL"),
        (0x30, "ASR"),
    ],
)
factory.generate_tests()
