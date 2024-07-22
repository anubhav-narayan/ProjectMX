from cocotb_test.simulator import run
import pytest
import os

test_dir = os.path.dirname(__file__)


def test_env():
    os.environ['SIM'] = 'verilator'
    run(
        verilog_sources=[
            os.path.join(test_dir, "../mxbiu.v"),
            os.path.join(test_dir, "../mxbus_dev.sv"),
            os.path.join(test_dir, "../mxbus_test.sv")
        ],
        toplevel="mxbus_test_ins",
        module="tb_mxbiu_ins",
        extra_args=[
            "--trace-fst"
        ]
    )
