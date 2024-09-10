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
	output logic       load,
	output logic       store,
	output logic [3:0] reg_src,
	output logic [3:0] reg_dst,
	output logic       load_en,
	output logic [1:0] mux_sel,
	output logic       lr,
	output  wire       alu_ce_n,
	output  wire       bs_ce_n,
	 input  wire [7:0] flags,
	 input  wire       fetch,
	 input  wire       insr_le,
	 input  wire [7:0] insr,
	 input  wire       ce_n
);
	wire [1:0] fsel;
	wire fval;

	assign alu_ce_n = ce_n;
	assign bs_ce_n = ce_n;

	reg [1:0] rom_jmp_f [7:0];
	reg [11:0] rom_mov [31:0];
	reg [11:0] rom_alu [7:0];
	reg [15:0] rom_jmp [31:0];
	reg [3:0] rom_lsu [7:0];

	// MOV ROM
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

	// ALU DP ROM
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

	// JMP ROM
	initial begin
		rom_jmp_f[3'h0] = 2'b00; // ZERO
		rom_jmp_f[3'h1] = 2'b00; // ZERO
		rom_jmp_f[3'h2] = 2'b01; // CARRY
		rom_jmp_f[3'h3] = 2'b01; // CARRY
		rom_jmp_f[3'h4] = 2'b10; // EQUAL
		rom_jmp_f[3'h5] = 2'b10; // EQUAL
		rom_jmp_f[3'h6] = 2'b11; // LT
		rom_jmp_f[3'h7] = 2'b11; // LT
		rom_jmp[5'h00] = 16'h6030; // JNZ &[D]
		rom_jmp[5'h01] = 16'h6060; // JNZ &[D]
		rom_jmp[5'h02] = 16'h6060; // JZ &[D]
		rom_jmp[5'h03] = 16'h6030; // JZ &[D]
		rom_jmp[5'h04] = 16'h6030; // JNC &[D]
		rom_jmp[5'h05] = 16'h6060; // JNC &[D]
		rom_jmp[5'h06] = 16'h6060; // JC &[D]
		rom_jmp[5'h07] = 16'h6030; // JC &[D]
		rom_jmp[5'h08] = 16'h6030; // JNE &[D]
		rom_jmp[5'h09] = 16'h6060; // JNE &[D]
		rom_jmp[5'h0A] = 16'h6060; // JE &[D]
		rom_jmp[5'h0B] = 16'h6030; // JE &[D]
		rom_jmp[5'h0C] = 16'h6030; // JGT &[D]
		rom_jmp[5'h0D] = 16'h6060; // JGT &[D]
		rom_jmp[5'h0E] = 16'h6060; // JLT &[D]
		rom_jmp[5'h0F] = 16'h6030; // JLT &[D]
		rom_jmp[5'h10] = 16'h6638; // JNZ &[INSP+D]
		rom_jmp[5'h11] = 16'h6060; // JNZ &[INSP+D]
		rom_jmp[5'h12] = 16'h6060; // JZ &[INSP+D]
		rom_jmp[5'h13] = 16'h6638; // JZ &[INSP+D]
		rom_jmp[5'h14] = 16'h6638; // JNC &[INSP+D]
		rom_jmp[5'h15] = 16'h6060; // JNC &[INSP+D]
		rom_jmp[5'h16] = 16'h6060; // JC &[INSP+D]
		rom_jmp[5'h17] = 16'h6638; // JC &[INSP+D]
		rom_jmp[5'h18] = 16'h6638; // JNE &[INSP+D]
		rom_jmp[5'h19] = 16'h6060; // JNE &[INSP+D]
		rom_jmp[5'h1A] = 16'h6060; // JE &[INSP+D]
		rom_jmp[5'h1B] = 16'h6638; // JE &[INSP+D]
		rom_jmp[5'h1C] = 16'h6638; // JGT &[INSP+D]
		rom_jmp[5'h1D] = 16'h6060; // JGT &[INSP+D]
		rom_jmp[5'h1E] = 16'h6060; // JLT &[INSP+D]
		rom_jmp[5'h1F] = 16'h6638; // JLT &[INSP+D]
	end

	initial begin
		rom_lsu[3'h0] = 4'h0;
		rom_lsu[3'h1] = 4'h1;
		rom_lsu[3'h2] = 4'h2;
		rom_lsu[3'h3] = 4'h7;
		rom_lsu[3'h4] = 4'hC;
		rom_lsu[3'h5] = 4'hD;
		rom_lsu[3'h6] = 4'hE;
		rom_lsu[3'h7] = 4'hF;
	end


	assign fsel = rom_jmp_f[insr[2:0]];
	assign fval = fsel[1] ? fsel[0] ? flags[3]
	                                : flags[2]
	                      : fsel[0] ? flags[1]
	                                : flags[0];

	always_comb begin
		if (~ce_n) begin
			if (fetch) begin
				{dst_f, src_b, src_a} = 12'h606;
				opcode = 4'hC;
				lr = 1'b0;
				load = 1'b0;
				store = 1'b0;
				reg_src = 4'h0;
				reg_dst = 4'h0;
				mux_sel = 2'b00;
				load_en = insr_le;
			end else begin
				case (insr[7:4])
					4'h0, 4'h1, 4'h2, 4'h3, 4'h4, 4'h6, 4'h7: begin
						{dst_f, src_b, src_a} = rom_alu[insr[6:4]];
						opcode = insr[3:0];
						lr = 1'b0;
						load = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b00;
						load_en = 1'b1;
					end
					4'h8, 4'h9: begin
						{dst_f, src_b, src_a} = rom_mov[insr[4:0]];
						opcode = 4'h0;
						lr = 1'b0;
						load = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b00;
						load_en = 1'b1;
					end
					4'hA: begin
						{dst_f, src_b, src_a, opcode} = rom_jmp[{insr[3:0], fval}];
						load = 1'b0;
						lr = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b00;
						load_en = 1'b1;
					end
					4'hB: begin
						load = ~insr[3];
						store = insr[3];
						{reg_dst, reg_src} = {2{rom_lsu[insr[2:0]]}};
						mux_sel = 2'b01;
						{dst_f, src_b, src_a} = 12'h000;
						opcode = 4'h0;
						lr = 1'b0;
						load_en = ~insr[3];
					end
					4'hC, 4'hD: begin
						{dst_f, src_b, src_a} = 12'h000;
						opcode = insr[3:0];
						lr = insr[4];
						load = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b10;
						load_en = 1'b1;
					end
					default : begin
						{dst_f, src_b, src_a} = 12'h000;
						opcode = 4'h0;
						load = 1'b0;
						lr = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b00;
						load_en = 1'b0;
					end
				endcase
			end
		end else begin
			{dst_f, src_b, src_a} = 12'h000;
			opcode = 4'h0;
			load = 1'b0;
			lr = 1'b0;
			store = 1'b0;
			reg_src = 4'h0;
			reg_dst = 4'h0;
			mux_sel = 2'b00;
			load_en = 1'b0;
		end
	end


endmodule