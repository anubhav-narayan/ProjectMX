from cocotb_test.simulator import run, clean
import pytest
import os

test_dir = os.path.dirname(__file__)


def test_ALU():
    os.environ['SIM'] = 'questa'
    run(
        verilog_sources=[
            os.path.join(test_dir, "../alu_cell.sv"),
            os.path.join(test_dir, "../alu11_cell.sv"),
            os.path.join(test_dir, "../alu11.sv"),
            os.path.join(test_dir, "../seu11.sv"),
        ],
        toplevel="seu11",
        module="tb_seu11",
        # gui=True,
        sim_args=[
            "-voptargs=\"+acc\""
        ]
    )