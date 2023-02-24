module mxalu11u (
	output [7:0] f,
	output       x,
	output       y,
	output       a_b,
	output       cn4_n,
	output       cn8_n,
	 input [3:0] opcode,
	 input [7:0] a,
	 input [7:0] b,
	 input       cs_n
);
	parameter TEST = 1;
	wire m, cn_n;
	wire [3:0] s;
	
	mxalu181_rom inst_mxalu181_rom(
		.s(s),
		.m(m),
		.cn_n(cn_n),
		.opcode(opcode), 
		.cs_n(cs_n)
	);

	mxalu_181 inst_mxalu_181(
		.f     (f),
		.x     (x),
		.y     (y),
		.a_b   (a_b),
		.cn4_n (cn4_n),
		.cn8_n (cn8_n),
		.a     (a),
		.b     (b),
		.s     (s),
		.m     (m),
		.cn_n  (cn_n)
	);

	initial begin
		if (TEST) begin
			$dumpfile("mxalu11u.vcd");
			$dumpvars(0, mxalu11u);
		end
	end


endmodule