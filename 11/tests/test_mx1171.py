import os

from cocotb_test.simulator import run


test_dir = os.path.dirname(__file__)
rtl_dir = os.path.dirname(test_dir)


def test_mx1171(request):
    os.environ.setdefault("SIM", "verilator")
    sim_build = os.path.join(test_dir, "sim_build")
    waves = request.config.getoption("--waves")
    wave_file = request.config.getoption("--wave-file")
    plus_args = []

    if waves:
        wave_file = wave_file or os.path.join(sim_build, "mx1171.fst")
        plus_args = ["--trace", "--trace-file", os.path.abspath(wave_file)]

    run(
        verilog_sources=[
            os.path.join(rtl_dir, "mx1171.sv"),
            os.path.join(rtl_dir, "alu11/seu11.sv"),
            os.path.join(rtl_dir, "alu11/seu11_rom.sv"),
            os.path.join(rtl_dir, "alu11/seu11_profile_rom.sv"),
            os.path.join(rtl_dir, "alu11/seu11_microcode_controller.sv"),
            os.path.join(rtl_dir, "alu11/alu11.sv"),
            os.path.join(rtl_dir, "alu11/alu11_cell.sv"),
            os.path.join(rtl_dir, "alu11/alu_cell.sv"),
            os.path.join(rtl_dir, "biu/mxbiu.sv"),
            os.path.join(rtl_dir, "ins/mx11_ins_fetch.sv"),
            os.path.join(rtl_dir, "lsu/mx11_lsu.sv"),
            os.path.join(rtl_dir, "registers/mxregs11.sv"),
            os.path.join(rtl_dir, "roms/mx11_sys_rom.sv"),
            os.path.join(rtl_dir, "extensions/shifter/mx11bshift.sv"),
            os.path.join(rtl_dir, "extensions/page_ctrl/page_ctrl.sv"),
        ],
        toplevel="mx11_71",
        module="tb_mx1171",
        sim_build=sim_build,
        work_dir=rtl_dir,
        waves=waves,
        plus_args=plus_args,
    )
