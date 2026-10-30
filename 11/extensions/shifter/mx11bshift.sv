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
/*
MNEMONIC | OPCODE | DESCRIPTION
---------+--------+-------------------------------------------
SHL imm3 | 0x00-0x07 | A <- A << imm3
ROL imm3 | 0x08-0x0F | A <- rotl(A, imm3)
SHR imm3 | 0x10-0x17 | A <- A >> imm3
ROR imm3 | 0x18-0x1F | A <- rotr(A, imm3)
ASL imm3 | 0x20-0x27 | A <- A << imm3 (same bit result as SHL without flags)
ASR imm3 | 0x30-0x37 | A <- signed(A) >>> imm3
*/

    logic arithmetic;

    assign m_wr_addr = 4'h0;
    assign m_rd_addr = 4'h0;
    assign m_wr_le = bs_ce & ~opcode[7];
    assign arithmetic = opcode[5] & opcode[4] & ~opcode[3];

    barrel_shift_8bit inst_barrel_shift_8bit (
        .en         (bs_ce),
        .lr         (opcode[4]),
        .rot        (opcode[3]),
        .arithmetic (arithmetic),
        .data       (m_rd_data),
        .shift      (opcode[2:0]),
        .out        (m_wr_data)
    );

endmodule

module barrel_shift_8bit (
    input  logic       en,
    input  logic       lr,
    input  logic       rot,
    input  logic       arithmetic,
    input  logic [7:0] data,
    input  logic [2:0] shift,
    output logic [7:0] out
);
    logic [7:0] shift4, shift2, shift1;
    logic [7:0] stage4, stage2, stage1;

    assign shift4 = lr
        ? (rot ? {data[3:0], data[7:4]}
               : (arithmetic ? {{4{data[7]}}, data[7:4]} : {4'b0, data[7:4]}))
        : (rot ? {data[3:0], data[7:4]} : {data[3:0], 4'b0});
    assign stage4 = shift[2] ? shift4 : data;

    assign shift2 = lr
        ? (rot ? {stage4[1:0], stage4[7:2]}
               : (arithmetic ? {{2{stage4[7]}}, stage4[7:2]} : {2'b0, stage4[7:2]}))
        : (rot ? {stage4[5:0], stage4[7:6]} : {stage4[5:0], 2'b0});
    assign stage2 = shift[1] ? shift2 : stage4;

    assign shift1 = lr
        ? (rot ? {stage2[0], stage2[7:1]}
               : (arithmetic ? {stage2[7], stage2[7:1]} : {1'b0, stage2[7:1]}))
        : (rot ? {stage2[6:0], stage2[7]} : {stage2[6:0], 1'b0});
    assign stage1 = shift[0] ? shift1 : stage2;

    assign out = en ? stage1 : data;

endmodule
