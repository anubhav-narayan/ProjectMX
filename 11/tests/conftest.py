def pytest_addoption(parser):
    group = parser.getgroup("mx1170")
    group.addoption(
        "--waves",
        action="store_true",
        help="enable Verilator FST waveform tracing for the mx1170 test",
    )
    group.addoption(
        "--wave-file",
        default=None,
        help="FST output path (default: 11/tests/sim_build/mx1170.fst)",
    )
