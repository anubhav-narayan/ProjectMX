`timescale 1ns/1ps
module mx1170_tb;
    typedef struct {
        logic       txn_start;
        logic       txn_ack;
        logic       txn_cpl;
        logic [7:0] data;
        logic [7:0] addr;
        logic       ready;
    } bus_t;

    bus_t ins_bus, rd_bus, wr_bus;
    bit clk, rst, nmi, irq;
    bit [3:0] rst_sys;

    always begin
        #2ns clk = ~clk;
    end

    always @(posedge clk) begin
        if (rst) begin
            rst_sys <= 4'b1111;
        end else begin
            rst_sys[0] <= 1'b0;
            rst_sys[1] <= rst_sys[0];
            rst_sys[2] <= rst_sys[1];
            rst_sys[3] <= rst_sys[2];
        end
    end

    mxbus_rom #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(8),
        .ROM_FILE("./ins.bin")
    ) rom (
        .clk(clk),
        .rst(rst_sys[1]),
        .s0_rd_txn_start(ins_bus.txn_start),
        .s0_rd_txn_ack(ins_bus.txn_ack),
        .s0_rd_txn_cpl(ins_bus.txn_cpl),
        .s0_rd_data(ins_bus.data),
        .s0_rd_addr(ins_bus.addr),
        .s0_rd_ready(ins_bus.ready)
    );

    mxbus_ram #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(8)
    ) ram (
        .clk(clk),
        .rst(rst_sys[1]),
        .s0_wr_txn_start(wr_bus.txn_start),
        .s0_wr_txn_ack(wr_bus.txn_ack),
        .s0_wr_txn_cpl(wr_bus.txn_cpl),
        .s0_wr_data(wr_bus.data),
        .s0_wr_addr(wr_bus.addr),
        .s0_wr_ready(wr_bus.ready),

        .s0_rd_txn_start(rd_bus.txn_start),
        .s0_rd_txn_ack(rd_bus.txn_ack),
        .s0_rd_txn_cpl(rd_bus.txn_cpl),
        .s0_rd_data(rd_bus.data),
        .s0_rd_addr(rd_bus.addr),
        .s0_rd_ready(rd_bus.ready)
    );

    mx11_70 dut (
        .clk(clk),
        .rst(rst_sys[2]),
        .ins_rd_txn_start(ins_bus.txn_start),
        .ins_rd_txn_ack(ins_bus.txn_ack),
        .ins_rd_txn_cpl(ins_bus.txn_cpl),
        .ins_rd_data(ins_bus.data),
        .ins_rd_addr(ins_bus.addr),
        .ins_rd_ready(ins_bus.ready),
        .data_rd_txn_start(rd_bus.txn_start),
        .data_rd_txn_ack(rd_bus.txn_ack),
        .data_rd_txn_cpl(rd_bus.txn_cpl),
        .data_rd_data(rd_bus.data),
        .data_rd_addr(rd_bus.addr),
        .data_rd_ready(rd_bus.ready),
        .data_wr_txn_start(wr_bus.txn_start),
        .data_wr_txn_ack(wr_bus.txn_ack),
        .data_wr_txn_cpl(wr_bus.txn_cpl),
        .data_wr_data(wr_bus.data),
        .data_wr_addr(wr_bus.addr),
        .data_wr_ready(wr_bus.ready),
        .nmi(nmi),
        .irq(irq)
    );

    task reset();
        rst = 1;
        #10ns;
        rst = 0;
    endtask

    initial begin
        clk = 0;
        rst = 0;
        nmi = 0;
        irq = 0;
        reset();

        #1000ns;

        $stop;
    end

endmodule: mx1170_tb