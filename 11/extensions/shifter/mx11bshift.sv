module mx11bshift (
    // MX/11 main register-file read and write buses
    output logic [3:0] m_rd_addr,
    input  logic [7:0] m_rd_data,
    output logic [3:0] m_wr_addr,
    output logic [7:0] m_wr_data,
    output logic       m_wr_le,

    // Shift controls are supplied by the extension decoder.
    input logic [7:0] opcode,
    input logic       bs_ce
);

    logic [7:0] shifted;

    assign m_wr_addr = opcode[5] ? 4'h0 : 4'h3;
    assign m_rd_addr = opcode[6] ? 4'h0 : 4'h3;
    assign m_wr_le = bs_ce & ~opcode[7];

    barrel_shift_8bit inst_barrel_shift_8bit (
        .en    (~bs_ce),
        .lr    (opcode[4]),
        .rot   (opcode[3]),
        .data  (m_rd_data),
        .shift (opcode[2:0]),
        .out   (m_wr_data)
    );

endmodule

module barrel_shift_8bit (
    input  logic       en,
    input  logic       lr,
    input  logic       rot,
    input  logic [7:0] data,
    input  logic [2:0] shift,
    output logic [7:0] out
);
    logic [7:0] shift4, shift2, shift1;
    logic [7:0] stage4, stage2, stage1;

    assign shift4 = lr
        ? (rot ? {data[3:0], data[7:4]} : {4'b0, data[7:4]})
        : (rot ? {data[3:0], data[7:4]} : {data[3:0], 4'b0});
    assign stage4 = shift[2] ? shift4 : data;

    assign shift2 = lr
        ? (rot ? {stage4[1:0], stage4[7:2]} : {2'b0, stage4[7:2]})
        : (rot ? {stage4[5:0], stage4[7:6]} : {stage4[5:0], 2'b0});
    assign stage2 = shift[1] ? shift2 : stage4;

    assign shift1 = lr
        ? (rot ? {stage2[0], stage2[7:1]} : {1'b0, stage2[7:1]})
        : (rot ? {stage2[6:0], stage2[7]} : {stage2[6:0], 1'b0});
    assign stage1 = shift[0] ? shift1 : stage2;

    assign out = en ? stage1 : data;

endmodule
