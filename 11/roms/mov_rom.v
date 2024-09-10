/*****************************************************************************
 * ALU ROM for MOV
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

module mov_rom(
	output  reg [3:0] src_a,
	output  reg [3:0] src_b,
	output  reg [7:0] load_addr,
	output wire [3:0] opcode,
	output wire       ce_n,
	 input wire [7:0] insr
);
	
	// chip enable
	assign ce_n = ~insr[7] & |(insr[6:5]);

	reg [7:0] rom_mov [31:0];

	initial begin
		rom_mov[ 0] = 8'h01; // A X
		rom_mov[ 1] = 8'h10; // X A
		rom_mov[ 2] = 8'h02; // A Y
		rom_mov[ 3] = 8'h20; // Y A
		rom_mov[ 4] = 8'h03; // A D
		rom_mov[ 5] = 8'h30; // D A
		rom_mov[ 6] = 8'h07; // A FLAGS
		rom_mov[ 7] = 8'h70; // FLAGS A
		rom_mov[ 8] = 8'h12; // X Y
		rom_mov[ 9] = 8'h21; // Y X
		rom_mov[10] = 8'h13; // X D
		rom_mov[11] = 8'h31; // D X
		rom_mov[12] = 8'h23; // Y D
		rom_mov[13] = 8'h32; // D Y
		rom_mov[14] = 8'h06; // A INSP
		rom_mov[15] = 8'h60; // INSP A
		rom_mov[16] = 8'h80; // SA A
		rom_mov[17] = 8'h91; // SX X
		rom_mov[18] = 8'hA2; // SY Y
		rom_mov[19] = 8'hB3; // SD D
		rom_mov[20] = 8'h08; // A SA
		rom_mov[21] = 8'h19; // X SX
		rom_mov[22] = 8'h2A; // Y SY
		rom_mov[23] = 8'h3B; // D SD
		rom_mov[24] = 8'hC4; // R0 DAR
		rom_mov[25] = 8'hD5; // R1 MBR
		rom_mov[26] = 8'hE6; // R2 INSP
		rom_mov[27] = 8'hF7; // R3 FLAGS
		rom_mov[28] = 8'h4C; // DAR R0
		rom_mov[29] = 8'h5D; // MBR R1
		rom_mov[30] = 8'h6E; // INSP R2
		rom_mov[31] = 8'h7F; // FLAGS R3
	end

	always @(*) begin
		if (~ce_n) begin
			{load_addr, src_a} = {4'h0, rom_mov[insr[4:0]]};
			opcode = 4'h0;
			src_b = 4'h0;
		end
	end

endmodule
