module mx11bshift (
    // Register Bus
     input logic [15:0][7:0] reg_line,
    output logic [15:0][7:0] data_line,
    output logic       [7:0] load_addr,
    // Operation
     input logic             lr,
     input logic       [3:0] opcode,
     input logic             bs_ce
);

    logic [7:0] data;
    logic [7:0] shifted;

    assign load_addr = 8'h00;

    reg_tap #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) inst_reg_tap (
        .data     (data),
        .reg_line (reg_line),
        .reg_addr (4'h0)
    );

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            data_line[i] = shifted;
        end
    end

    barrel_shift_8bit inst_barrel_shift_8bit (
        .en    (~bs_ce),
        .lr    (lr),
        .rot   (opcode[3]),
        .data  (data),
        .shift (opcode[2:0]),
        .out   (shifted)
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
