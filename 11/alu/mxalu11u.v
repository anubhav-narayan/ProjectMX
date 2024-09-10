/*****************************************************************************
 * MX 1 byte Data 1 byte Address Unsigned ALU (MXALU11U)
 * Copyright 2023 Anubhav Mattoo
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 * 
 * Author : Anubhav Mattoo <anubhavmattoo@outlook.com>
 * Date : 2023 - 02 - 24
 ****************************************************************************/

module mxalu11u (
	output [7:0] f,
	output       x,
	output       y,
	output [4:0] flags,
	 input [3:0] opcode,
	 input [7:0] a,
	 input [7:0] b,
	 input       cs_n
);
	wire m, cn_n, cn4_n, cn8_n, a_b;
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

	alu_flags inst_alu_flags(
		.flags(flags),
		.f(f),
		.a_b(a_b),
		.cn_n(cn_n),
		.cn4_n(cn4_n),
		.cn8_n(cn8_n)
	);


`ifdef WAVE
	initial begin
		if(`WAVE == "ALU") begin
			$dumpfile("mxalu11u.vcd");
			$dumpvars(0, mxalu11u);
		end
	end
`endif

endmodule
