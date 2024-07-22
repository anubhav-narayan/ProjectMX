module mxregs#(
    parameter WORD_LENGTH = 8,
    parameter DEPTH = 16
)(
	output wire [DEPTH-1:0][WORD_LENGTH-1:0] reg_line,
	 input wire [DEPTH-1:0][WORD_LENGTH-1:0] data_line,
	 input wire            [            7:0] load_addr,
	 input wire                              load_en,
	 input wire                              clk,
	 input wire                              rst
);

	wire [DEPTH-1:0] load;

	mxreg_load_decoder_11#(
		.DEPTH(DEPTH)
	) inst_ldec (
		.load     (load),
		.load_addr(load_addr),
		.load_en  (load_en)
	);

	reg_bank#(
		.WORD_LENGTH(WORD_LENGTH),
		.DEPTH(DEPTH)
	) inst_reg_bank (
		.q   (reg_line),
		.data(data_line),
		.load(load),
		.clk (clk),
		.rst (rst)
	);

endmodule


module mxreg_load_decoder_11#(
    parameter DEPTH = 16
)(
	output  reg [        DEPTH-1:0] load,
	 input wire [              7:0] load_addr,
	 input wire                     load_en
);

	always_comb begin
		if (load_en) begin
			case (load_addr)
				8'h00: load = 16'h0001; // A
				8'h01: load = 16'h0002; // X
				8'h02: load = 16'h0004; // Y
				8'h03: load = 16'h0008; // D
				8'h04: load = 16'h0010; // DAR
				8'h05: load = 16'h0020; // MBR
				8'h06: load = 16'h0040; // INSP
				8'h07: load = 16'h0080; // FLAGS
				8'h08: load = 16'h0100; // SA
				8'h09: load = 16'h0200; // SX
				8'h0A: load = 16'h0400; // SY
				8'h0B: load = 16'h0800; // SD
				8'h0C: load = 16'h1000; // R0
				8'h0D: load = 16'h2000; // R1
				8'h0E: load = 16'h4000; // R2
				8'h0F: load = 16'h8000; // R3
				8'h10: load = 16'h0081; // FLAGS, A
				8'h11: load = 16'h0088; // FLAGS, D
				default: load = 16'h0000;
			endcase
		end else begin
			load = 16'h0;
		end
	end

endmodule


module reg_bank#(
    parameter WORD_LENGTH = 8,
    parameter DEPTH = 16
)(
	output [DEPTH-1:0][WORD_LENGTH-1:0] q,
	 input [DEPTH-1:0][WORD_LENGTH-1:0] data,
	 input [DEPTH-1:0] load,
	 input        clk,
	 input        rst
);
    
    generate
		genvar x;
		for (x = 0; x < DEPTH; x = x+1) begin : regs
			load_register#(
			    .WORD_LENGTH(WORD_LENGTH)
			) inst_ldr (
				.q   (q[x]),
				.data(data[x]),
				.clk (clk),
				.rst (rst),
				.load(load[x])
			);
		end
	endgenerate

endmodule


module load_register#
(
    parameter WORD_LENGTH = 8
)
(
	output reg [WORD_LENGTH-1:0] q,
	 input     [WORD_LENGTH-1:0] data,
	 input           load,
	 input           clk,
	 input           rst
);

	always @(posedge clk) begin
		if(rst) begin
			q <= 0;
		end else begin
			if (load) begin
				q <= data;
			end
		end
	end

endmodule