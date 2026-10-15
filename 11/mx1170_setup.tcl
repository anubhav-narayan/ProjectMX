proc mx_com {} {

    # Create libraries if required
    if {![file exists mx1170]} {
        vlib mx1170
    }

    if {![file exists mx1170_tb]} {
        vlib mx1170_tb
    }

    # Design files
    vlog -sv -work mx1170 ./mx1170.sv

    vlog -sv -work mx1170 ./alu11/seu11.sv
    vlog -sv -work mx1170 ./alu11/seu11_rom.sv
    vlog -sv -work mx1170 ./alu11/alu11.sv
    vlog -sv -work mx1170 ./alu11/alu11_cell.sv
    vlog -sv -work mx1170 ./alu11/alu_cell.sv

    vlog -sv -work mx1170 ./biu/mxbiu.sv

    vlog -sv -work mx1170 ./ins/mx11_ins_fetch.sv
    vlog -sv -work mx1170 ./lsu/mx11_lsu.sv
    vlog -sv -work mx1170 ./registers/mxregs11.sv
    vlog -sv -work mx1170 ./roms/mx11_sys_rom.sv

    # Testbench files
    vlog -sv -work mx1170_tb ./biu/mxbus_dev.sv
    vlog -sv -work mx1170_tb ./mx1170_tb.sv
}

proc mx_com_tb {} {
    # Testbench files
    vlog -sv -work mx1170_tb ./biu/mxbus_dev.sv
    vlog -sv -work mx1170_tb ./mx1170_tb.sv
}

proc mx_elab {} {
    vsim \
        -L mx1170 \
        -L mx1170_tb \
        mx1170_tb.mx1170_tb
}

proc mx_elab_debug {} {
    vsim \
        -L mx1170 \
        -L mx1170_tb \
        -debugDB \
        mx1170_tb.mx1170_tb
}