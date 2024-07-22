module mxseu_dut(
	// Register Bus
	 input logic [15:0][7:0] reg_line,
	output logic [15:0][7:0] data_line,
	output logic       [7:0] load_addr,
	output logic             load_en,
	// Outer Logic
	input  wire       fetch,
	input  wire [7:0] insr,
	input  wire       ce_n
);
	
	// Wires
	wire [3:0] src_a;
	wire [3:0] src_b;
	wire [3:0] dst_f;
	wire [3:0] opcode;
	wire       alu_ce_n;


	su_isa_rom inst_su_isa_rom(
		.src_a    (src_a),
		.src_b    (src_b),
		.dst_f    (dst_f),
		.opcode   (opcode),
		.load_en  (load_en),
		.alu_ce_n (alu_ce_n),
		.fetch    (fetch),
		.insr     (insr),
		.ce_n     (ce_n)
	);

	mx11seu inst_mx11seu (
		.reg_line  (reg_line),
		.data_line (data_line),
		.load_addr (load_addr),
		.opcode    (opcode),
		.fetch     (fetch),
		.src_a     (src_a),
		.src_b     (src_b),
		.dst_f     (dst_f),
		.cs_n      (alu_ce_n)
	);

endmodule