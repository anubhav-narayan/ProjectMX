from cocotb_test.simulator import run
import pytest
import os

test_dir = os.path.dirname(__file__)


def test_ALU():
    run(
        verilog_sources=[
            os.path.join(test_dir, "../mxalu11u_intel.v")
        ],
        toplevel="mxalu11u_intel",
        module="tb_mxalu11u",
        includes=[
            "/usr/share/yosys/intel_alm/common/",
        ],
        defines=[
            "WAVE=1",
        ],
        # extra_args=[
        #     "--coverage",
        #     "--trace-fst"
        # ]
    )
