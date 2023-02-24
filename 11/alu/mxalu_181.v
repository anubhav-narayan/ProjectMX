module mxalu_181(
	output [7:0] f,
	output       x,
	output       y,
	output       a_b,
	output       cn4_n,
	output       cn8_n,
	 input [7:0] a,
	 input [7:0] b,
	 input [3:0] s,
	 input       m,
	 input       cn_n
);
	
	wire xl, yl, cnx, xh, yh;
	wire [1:0] a_b_x;

	alu181 inst_alu0(
		.f    (f[3:0]),
		.a_b  (a_b_x[0]),
		.x    (xl),
		.y    (yl),
		.cn4_n(cn4_n),
		.a    (a[3:0]),
		.b    (b[3:0]),
		.m    (m),
		.s    (s),
		.cn_n (cn_n)
	);

	alu181 inst_alu1(
		.f    (f[7:4]),
		.a_b  (a_b_x[1]),
		.x    (xh),
		.y    (yh),
		.cn4_n(cn8_n),
		.a    (a[7:4]),
		.b    (b[7:4]),
		.m    (m),
		.s    (s),
		.cn_n (cn4_n)
	);

	fast_carry inst_cgp(
		.cnx  (cnx),
		.go_n (x),
		.po_n (y),
		.g_n  ({xh, xl}),
		.p_n  ({yh, yl}),
		.cn   (cn_n)
	);

	assign a_b = &a_b_x;

endmodule