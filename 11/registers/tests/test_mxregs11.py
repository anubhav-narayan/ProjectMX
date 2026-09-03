from cocotb_test.simulator import run, clean
import pytest
import os

test_dir = os.path.dirname(__file__)


def test_REGS():
    os.environ['SIM'] = 'questa'
    run(
        verilog_sources=[
            os.path.join(test_dir, "../mxregs11.sv"),
        ],
        toplevel="mxregs11",
        module="tb_mxregs11",
        # gui=True,
        sim_args=[
            "-voptargs=\"+acc\""
        ]
    )