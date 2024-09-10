from cocotb_test.simulator import run
import pytest
import os

test_dir = os.path.dirname(__file__)


def test_SEU():
    os.environ['SIM'] = 'verilator'
    run(
        verilog_sources=[
            os.path.join(test_dir, "../../alu/fast_carry.v"),
            os.path.join(test_dir, "../../alu/74181.v"),
            os.path.join(test_dir, "../../alu/mxalu_181.v"),
            os.path.join(test_dir, "../../alu/mxalu_rom.sv"),
            os.path.join(test_dir, "../../alu/alu_flags.v"),
            os.path.join(test_dir, "../../alu/mxalu11u.v"),
            os.path.join(test_dir, "../../registers/reg_tap.sv"),
            os.path.join(test_dir, "../mxseu.sv"),
            os.path.join(test_dir, "../../roms/isa_rom.sv"),
            os.path.join(test_dir, "./mxseu_dut.sv")
        ],
        toplevel="mxseu_dut",
        module="tb_mxseu",
        extra_args=[
            "-Wno-casex",
            "--trace-fst",
            "--dump-graph",
            "--dump-tree-json"
        ]
    )
