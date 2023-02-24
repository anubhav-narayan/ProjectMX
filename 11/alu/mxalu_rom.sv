/*****************************************************************************
 * Intel 74181 Custom ROM for MXALU11U
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
/*
+-------+--------+-------------+---+-----+---+
| INSTR | OPCODE | DESCRIPTION | M | ~Cn | S |
+-------+--------+-------------+---+-----+---+
|  BUF  |    0   |       A     | 1 |  X  | F |
+-------+--------+-------------+---+-----+---+
|  NOT  |    1   |      ~A     | 1 |  X  | 0 |
+-------+--------+-------------+---+-----+---+
|  NAND |    2   |     A~&B    | 1 |  X  | 4 |
+-------+--------+-------------+---+-----+---+
|  XOR  |    3   |     A^B     | 1 |  X  | 6 |
+-------+--------+-------------+---+-----+---+
|  XNOR |    4   |     A~^B    | 1 |  X  | 9 |
+-------+--------+-------------+---+-----+---+
|  AND  |    5   |     A&B     | 1 |  X  | B |
+-------+--------+-------------+---+-----+---+
|   OR  |    6   |     A|B     | 1 |  X  | E |
+-------+--------+-------------+---+-----+---+
|  NOR  |    7   |     A~|B    | 1 |  X  | 1 |
+-------+--------+-------------+---+-----+---+
|  ADD  |    8   |     A+B     | 0 |  1  | 9 |
+-------+--------+-------------+---+-----+---+
|  ADC  |    9   |    A+B+1    | 0 |  0  | 9 |
+-------+--------+-------------+---+-----+---+
|  SUB  |    A   |     A-B     | 0 |  0  | 6 |
+-------+--------+-------------+---+-----+---+
|  SBB  |    B   |    A-B-1    | 0 |  1  | 6 |
+-------+--------+-------------+---+-----+---+
|  INCR |    C   |     A+1     | 0 |  0  | 0 |
+-------+--------+-------------+---+-----+---+
|  DECR |    D   |     A-1     | 0 |  1  | F |
+-------+--------+-------------+---+-----+---+
|   X2  |    E   |    A + A    | 0 |  1  | C |
+-------+--------+-------------+---+-----+---+
|  CLR  |    F   |      0      | 1 |  X  | 3 |
+-------+--------+-------------+---+-----+---+
 */

module mxalu181_rom(
	output  reg [3:0] s,
	output  reg       m,
	output  reg       cn_n,
	 input wire [3:0] opcode,
	 input wire       cs_n
);
	
	reg [5:0] rom [15:0];
	
	initial begin
		rom[ 0] = 6'h3F;
		rom[ 1] = 6'h30;
		rom[ 2] = 6'h34;
		rom[ 3] = 6'h36;
		rom[ 4] = 6'h39;
		rom[ 5] = 6'h3B;
		rom[ 6] = 6'h3E;
		rom[ 7] = 6'h31;
		rom[ 8] = 6'h19;
		rom[ 9] = 6'h09;
		rom[10] = 6'h06;
		rom[11] = 6'h16;
		rom[12] = 6'h00;
		rom[13] = 6'h1F;
		rom[14] = 6'h1C;
		rom[15] = 6'h33;
	end

	always_comb begin
		if (~cs_n) begin
			{m, cn_n, s} = rom[opcode];
		end else begin
			{m, cn_n, s} = 6'h0;
		end
	end

endmodule
