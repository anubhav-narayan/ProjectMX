from cocotb_test.simulator import run
import pytest
import os

test_dir = os.path.dirname(__file__)


def test_ALU():
    run(
        verilog_sources=[
            os.path.join(test_dir, "../fast_carry.v"),
            os.path.join(test_dir, "../74181.v"),
            os.path.join(test_dir, "../mxalu_181.v"),
            os.path.join(test_dir, "../mxalu_rom.v"),
            os.path.join(test_dir, "../mxalu11u.v")
        ],
        toplevel="mxalu11u",
        module="tb_mxalu11u"
    )
