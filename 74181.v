/********************************************
 * INTEL 181 CLONE
 ********************************************/

module alu181 (
	output [3:0] f,
	output       a_b,
	output       x,
	output       y,
	output       cn4_n,
	 input [3:0] a,
	 input [3:0] b,
	 input [3:0] s,
	 input       m,
	 input       cn_n
);

	wire [3:0] s21_data, s31_data;
	wire [3:0] sr_data;
	wire [8:0] gr_data;
	wire [3:0] sr1;
	wire [5:0] sr2;
	wire [7:0] sr3;

	assign sr_data[0] = ~(cn_n & ~m);

	assign gr_data = {s31_data[3], s21_data[3], s31_data[2], s21_data[2], s31_data[1], s21_data[1], s31_data[0], s21_data[0], cn_n};
	assign sr1 = {cn_n, s21_data[0], s31_data[0], ~m};
	assign sr2 = {cn_n, s21_data[0], s21_data[1], s31_data[0], s31_data[1], ~m};
	assign sr3 = {cn_n, s21_data[0], s21_data[1], s21_data[2], s31_data[0], s31_data[1], s31_data[2], ~m};

	s52reduction inst_s520(
		.f({s21_data[0], s31_data[0]}),
		.s(s),
		.a(a[0]),
		.b(b[0])
	);

	s52reduction inst_s521(
		.f({s21_data[1], s31_data[1]}),
		.s(s),
		.a(a[1]),
		.b(b[1])
	);

	s52reduction inst_s522(
		.f({s21_data[2], s31_data[2]}),
		.s(s),
		.a(a[2]),
		.b(b[2])
	);

	s52reduction inst_s523(
		.f({s21_data[3], s31_data[3]}),
		.s(s),
		.a(a[3]),
		.b(b[3])
	);
	
	sr1reduction sr1r0(
		.dt(sr1),
		.f (sr_data[1])
	);
	
	sr2reduction sr2r0(
		.dt(sr2),
		.f (sr_data[2])
	);

	sr3reduction sr3r0(
		.dt(sr3),
		.f (sr_data[3])
	);

	gr grr0(
		.cn4_n(cn4_n),
		.x    (x),
		.y    (y),
		.dt   (gr_data)
	);

	assign f = sr_data ^ (s31_data ^ s21_data);
	assign a_b = &f;


endmodule

module s21reduction(
	output f,
	 input [4:0] dt
);
	assign f = ~((&dt[4:2]) | (&dt[2:0]));
endmodule

module s31reduction(
	output f,
	 input [4:0] dt
);
	assign f = ~((&dt[4:3]) | (&dt[2:1]) | (dt[0]));
endmodule

module s52reduction(
	output [1:0] f,
	 input [3:0] s,
	 input       a,
	 input       b
);
	s21reduction inst_s21(
		.f (f[1]),
		.dt({b, s[3], a, s[2], ~b})
	);

	s31reduction inst_s31(
		.f (f[0]),
		.dt({~b, s[1:0], b, a})
	);
endmodule

module gr(
	output y, x, cn4_n,
	input [8:0] dt
);
	
	assign x = ~(dt[7] & dt[5] & dt[3] & dt[1]);
	assign y = ~|{dt[8], (&dt[7:6]), (&{dt[7], dt[5:4]}), (&{dt[7], dt[5], dt[3:2]})};
	assign cn4_n = ~((x & dt[0]) | ~y);

endmodule

module sr1reduction(
	output f,
	 input [3:0] dt
);
	assign f = ~|{(&{dt[3:2], dt[0]}), (&dt[1:0])};
endmodule

module sr2reduction(
	output f,
	 input [5:0] dt
);
	assign f = ~((&{dt[5:3], dt[0]}) | (&{dt[3:2], dt[0]}) | (&dt[1:0]));
endmodule

module sr3reduction(
	output f,
	 input [7:0] dt
);
	assign f = ~((&{dt[7:4], dt[0]}) | (&{dt[5:3], dt[0]}) | (&{dt[4], dt[2], dt[0]}) | (&dt[1:0]));
endmodule