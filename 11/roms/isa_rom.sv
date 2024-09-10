/*****************************************************************************
 * MX11SU ISA ROM
 * Copyright 2024 Anubhav Mattoo
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
 * Date : 2024 - 05 - 09
 ****************************************************************************/
// `timescale 1ns/1ps

module su_isa_rom(
	output logic [3:0] src_a,
	output logic [3:0] src_b,
	output logic [3:0] dst_f,
	output logic [3:0] opcode,
	output  wire       load_en,
	output  wire       alu_ce_n,
	 input  wire [7:0] flags,
	 input  wire       fetch,
	 input  wire [7:0] insr,
	 input  wire       ce_n
);

	wire rom_alu_ce_n;
	wire rom_mov_ce_n;
	wire rom_jmp_ce_n;

	assign rom_alu_ce_n = insr[7];
	assign rom_mov_ce_n = |{~insr[7], insr[6], insr[5]};
	assign rom_jmp_ce_n = insr[7:4] ^ 4'hA;
	assign load_en = fetch | (~ce_n & |insr);
	assign alu_ce_n = ce_n;

	reg [11:0] rom_mov [31:0];
	reg [11:0] rom_alu [7:0];
	reg [15:0] rom_jmp [31:0];

	initial begin
		rom_mov[5'h00] = 12'h001; // A X
		rom_mov[5'h01] = 12'h100; // X A
		rom_mov[5'h02] = 12'h002; // A Y
		rom_mov[5'h03] = 12'h200; // Y A
		rom_mov[5'h04] = 12'h003; // A D
		rom_mov[5'h05] = 12'h300; // D A
		rom_mov[5'h06] = 12'h007; // A FLAGS
		rom_mov[5'h07] = 12'h700; // FLAGS A
		rom_mov[5'h08] = 12'h102; // X Y
		rom_mov[5'h09] = 12'h201; // Y X
		rom_mov[5'h0A] = 12'h103; // X D
		rom_mov[5'h0B] = 12'h301; // D X
		rom_mov[5'h0C] = 12'h203; // Y D
		rom_mov[5'h0D] = 12'h302; // D Y
		rom_mov[5'h0E] = 12'h006; // A INSP
		rom_mov[5'h0F] = 12'h600; // INSP A
		rom_mov[5'h10] = 12'h800; // SA A
		rom_mov[5'h11] = 12'h901; // SX X
		rom_mov[5'h12] = 12'hA02; // SY Y
		rom_mov[5'h13] = 12'hB03; // SD D
		rom_mov[5'h14] = 12'h008; // A SA
		rom_mov[5'h15] = 12'h109; // X SX
		rom_mov[5'h16] = 12'h20A; // Y SY
		rom_mov[5'h17] = 12'h30B; // D SD
		rom_mov[5'h18] = 12'hC04; // R0 DAR
		rom_mov[5'h19] = 12'hD05; // R1 MBR
		rom_mov[5'h1A] = 12'hE06; // R2 INSP
		rom_mov[5'h1B] = 12'hF07; // R3 FLAGS
		rom_mov[5'h1C] = 12'h40C; // DAR R0
		rom_mov[5'h1D] = 12'h50D; // MBR R1
		rom_mov[5'h1E] = 12'h60E; // INSP R2
		rom_mov[5'h1F] = 12'h70F; // FLAGS R3
	end

	initial begin
		rom_alu[3'h0] = 12'h010; // 00_10_01: A X A
		rom_alu[3'h1] = 12'h001; // 00_00_01: A A X
		rom_alu[3'h2] = 12'h002; // 00_00_10: A A Y
		rom_alu[3'h3] = 12'h003; // 00_00_11: A A D
		rom_alu[3'h4] = 12'h330; // 11_11_00: D D A
		rom_alu[3'h5] = 12'h331; // 11_11_01: D D X
		rom_alu[3'h6] = 12'h332; // 11_11_10: D D Y
		rom_alu[3'h7] = 12'h333; // 11_11_11: D D D
	end

	always @(*) begin
		case ({ce_n, fetch})
			2'b00: begin
				case ({rom_alu_ce_n, rom_mov_ce_n, rom_jmp_ce_n})
					3'b011: begin
						{dst_f, src_b, src_a} = rom_alu[insr[6:4]];
						opcode = 4'h0;
					end
					3'b101: begin
						{dst_f, src_b, src_a} = rom_mov[insr[4:0]];
						opcode = insr[3:0];
					end
					3'b110: begin
						case (insr[3:0])
							4'h0: begin
								{dst_f, src_b, src_a, opcode} = flags[0] ? 16'h6060 : 16'h6030; // JNZ &[D]
							end
							4'h1: begin
								{dst_f, src_b, src_a, opcode} = flags[0] ? 16'h6030 : 16'h6060; // JZ &[D]
							end
							4'h2: begin
								{dst_f, src_b, src_a, opcode} = flags[1] ? 16'h6060 : 16'h6030; // JNC &[D]
							end
							4'h3: begin
								{dst_f, src_b, src_a, opcode} = flags[1] ? 16'h6030 : 16'h6060; // JC &[D]
							end
							4'h4: begin
								{dst_f, src_b, src_a, opcode} = flags[3] ? 16'h6030 : 16'h6060; // JGT &[D]
							end
							4'h5: begin
								{dst_f, src_b, src_a, opcode} = flags[4] ? 16'h6030 : 16'h6060; // JLT &[D]
							end
							4'h6: begin
								{dst_f, src_b, src_a, opcode} = flags[3] & flags[2] ? 16'h6030 : 16'h6060; // JGE &[D]
							end
							4'h7: begin
								{dst_f, src_b, src_a, opcode} = flags[4] & flags[2] ? 16'h6030 : 16'h6060; // JLE &[D]
							end
							4'h8: begin
								{dst_f, src_b, src_a, opcode} = flags[0] ? 16'h6060 : 16'h6638; // JNZ &[INSP+D]
							end
							4'h9: begin
								{dst_f, src_b, src_a, opcode} = flags[0] ? 16'h6638 : 16'h6060; // JZ &[INSP+D]
							end
							4'hA: begin
								{dst_f, src_b, src_a, opcode} = flags[1] ? 16'h6060 : 16'h6638; // JNC &[INSP+D]
							end
							4'hB: begin
								{dst_f, src_b, src_a, opcode} = flags[1] ? 16'h6638 : 16'h6060; // JC &[INSP+D]
							end
							4'hC: begin
								{dst_f, src_b, src_a, opcode} = flags[3] ? 16'h6638 : 16'h6060; // JGT &[INSP+D]
							end
							4'hD: begin
								{dst_f, src_b, src_a, opcode} = flags[4] ? 16'h6638 : 16'h6060; // JLT &[INSP+D]
							end
							4'hE: begin
								{dst_f, src_b, src_a, opcode} = flags[3] & flags[2] ? 16'h6638 : 16'h6060; // JGE &[INSP+D]
							end
							4'hF: begin
								{dst_f, src_b, src_a, opcode} = flags[4] & flags[2] ? 16'h6638 : 16'h6060; // JLE &[INSP+D]
							end
						endcase
					end
					default : begin
						{dst_f, src_b, src_a} = 12'h000;
						opcode = 4'h0;
					end
				endcase
			end
			2'b01: begin
				{dst_f, src_b, src_a} = 12'h606;
				opcode = 4'hC;
			end
			default: begin
				{dst_f, src_b, src_a} = 12'h000;
				opcode = 4'h0;
			end
		endcase
	end


endmodule