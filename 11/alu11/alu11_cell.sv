module alu11_cell (
	 input  wire a,
	 input  wire b,
	 input  wire carry_in,
	 input  wire [3:0] opcode,
	output logic f,
	output logic g,
	output logic p,
	output logic carry_out
);

	wire [2:0] op_int;
	logic b_int;
	logic [1:0] b_sel;


	/*
		0 BUF
		1 CLR
		2 NOT
		3 XOR
		4 AND
		5 OR
		6
		7
		8 INCR
		9 DECR
		A ADD
		B ADC
		C SUB
		D SBB
		E CMP
		F
	*/

	always_comb begin
		case (b_sel)
			2'h0: begin
				b_int = b;
			end
			2'h1: begin
				b_int = ~b;
			end
			2'h2: begin
				b_int = 0;
			end
			2'h3: begin
				b_int = 1;
			end
			default: begin
				b_int = b;
			end
		endcase
	end

	always_comb begin
		case (opcode)
			4'hC, 4'hD, 4'hE: begin
				b_sel = 2'h1;
			end
			4'h8: begin
				b_sel = 2'h2;
			end
			4'h9: begin
				b_sel = 2'h3;
			end
			default: begin
				b_sel = 2'h0;
			end
		endcase
	end

	assign op_int = opcode[3] ? 3'h6 : opcode[2:0];

	alu_cell inst_alu_cell(
		.a         (a),
		.b         (b_int),
		.carry_in  (carry_in),
		.opcode    (op_int),
		.f         (f),
		.g         (g),
		.p         (p),
		.carry_out (carry_out)
	);


endmodule : alu11_cell