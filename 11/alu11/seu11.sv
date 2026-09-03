module seu11(
	// Main Read Bus
	 input logic [7:0] m_rd_data,
	// Auxillary Read Bus
	 input logic [7:0] a_rd_data,
	// Main Write Bus
	output  wire [7:0] m_wr_data,
	// Auxillary Write Bus
	output  wire [7:0] a_wr_data,
	// Immediate
	 input  wire       ldi,
	 input  wire [7:0] imm8,  
	// Instruction
	 input  wire [3:0] alu_ins,
	// Flags
	 input  wire [7:0] flags_in,
	output  wire [7:0] flags,
	// Carry
	 input  wire carry_in,
	output  wire carry_out
);
	
	wire [5:0] flags_int;
	assign flags = (alu_ins == 4'hE) ? {flags_in[7:6], flags_int} : {flags_in[7:3], flags_int[2:0]};
	assign a_wr_data = flags;
	
	alu11 inst_alu11(
		.a         (ldi?imm8:m_rd_data),
		.b         (a_rd_data),
		.carry_in  (carry_in),
		.opcode    (alu_ins),
		.f         (m_wr_data),
		.g         (),
		.p         (),
		.carry_out (carry_out),
		.flags     (flags_int)
	);


endmodule : seu11