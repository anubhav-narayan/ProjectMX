import os

from cocotb_test.simulator import run


test_dir = os.path.dirname(__file__)


def test_mx11bshift():
    os.environ.setdefault("SIM", "verilator")
    run(
        verilog_sources=[
            os.path.join(test_dir, "../mx11bshift.sv"),
        ],
        toplevel="mx11bshift",
        module="tb_mx11bshift",
        sim_build=os.path.join(test_dir, "sim_build")
    )
