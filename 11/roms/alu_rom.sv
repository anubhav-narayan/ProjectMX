/*****************************************************************************
 * ALU Datapath with ROM
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
 * Date : 2023 - 03 - 12
 ****************************************************************************/
`timescale 1ns/1ps
/*
ALU
+---+-----------+---------------+
| 0 |   CREG    |     OPCODE    |
+---+-----------+---------------+

CREG    F    A    B    MODIFIER
 000    A    X    Y     -----
 001    A    X    A     X
 010    A    Y    A     Y
 011    A    D    A     D
 100    D    A    D     D, A
 101    D    X    D     D, X
 110    D    Y    D     D, Y
 111    D    D    D     D, D
*/

module alu_rom(
	output  reg [3:0] src_a, src_b,
	output  reg [7:0] load_addr,
	output wire [3:0] opcode,
	output wire       ce_n,
	 input wire [7:0] insr
);

	// chip enable
	assign ce_n = insr[7];
	// opcode
	assign opcode = insr[3:0];

	reg [11:0] rom_alu [7:0];

	initial begin
		rom_alu[0] = 12'h021; // 00_10_01: A Y X
		rom_alu[1] = 12'h001; // 00_00_01: A A X
		rom_alu[2] = 12'h002; // 00_00_10: A A Y
		rom_alu[3] = 12'h003; // 00_00_11: A A D
		rom_alu[4] = 12'h330; // 11_11_00: D D A
		rom_alu[5] = 12'h331; // 11_11_01: D D X
		rom_alu[6] = 12'h332; // 11_11_10: D D Y
		rom_alu[7] = 12'h333; // 11_11_11: D D D
	end

	always_comb begin
		if (~ce_n) begin
			{load_addr, src_b, src_a} = {4'h1, rom_alu[insr[6:4]]};
		end
	end

endmodule