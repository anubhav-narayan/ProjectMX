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
	output logic       ldi,
	output logic [7:0] ldv,
	output logic       load,
	output logic       store,
	output logic [3:0] reg_src,
	output logic [3:0] reg_dst,
	output logic       load_en,
	output logic [1:0] mux_sel,
	output logic       lr,
	output  wire       alu_ce_n,
	output  wire       bs_ce_n,
	output  wire       halt,
	 input  wire [7:0] flags,
	 input  wire       fetch,
	 input  wire       intr,
	 input  wire       insr_le,
	 input  wire [7:0] insr,
	 input  wire       ce_n
);
	wire [1:0] fsel;
	wire fval;

	assign alu_ce_n = ce_n;
	assign bs_ce_n = ce_n;
	assign halt = &insr;

	reg [1:0] rom_jmp_f [7:0];
	reg [11:0] rom_mov [31:0];
	reg [1:0] rom_alu_sel [15:0];
	reg [11:0] rom_alu [23:0];
	reg [15:0] rom_jmp [31:0];
	reg [3:0] rom_lsu [7:0];

	// MOV ROM
	initial begin
		rom_mov[5'h00] = 12'h100; // X A
		rom_mov[5'h01] = 12'h200; // Y A
		rom_mov[5'h02] = 12'h700; // FLAGS A
		rom_mov[5'h03] = 12'h007; // A FLAGS
		rom_mov[5'h04] = 12'h102; // X Y
		rom_mov[5'h05] = 12'h201; // Y X
		rom_mov[5'h06] = 12'h103; // X D
		rom_mov[5'h07] = 12'h203; // Y D
		rom_mov[5'h08] = 12'h00C; // A R0
		rom_mov[5'h09] = 12'h10D; // X R1
		rom_mov[5'h0A] = 12'h20E; // Y R2
		rom_mov[5'h0B] = 12'h30F; // D R3
		rom_mov[5'h0C] = 12'hC00; // R0 A
		rom_mov[5'h0D] = 12'hD01; // R1 X
		rom_mov[5'h0E] = 12'h502; // MBR Y
		rom_mov[5'h0F] = 12'hF03; // R3 D
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
		rom_alu_sel[4'h0] = 2'h1; 
		rom_alu_sel[4'h1] = 2'h1;
		rom_alu_sel[4'h2] = 2'h0;
		rom_alu_sel[4'h3] = 2'h0;
		rom_alu_sel[4'h4] = 2'h0;
		rom_alu_sel[4'h5] = 2'h0;
		rom_alu_sel[4'h6] = 2'h0;
		rom_alu_sel[4'h7] = 2'h0;
		rom_alu_sel[4'h8] = 2'h0;
		rom_alu_sel[4'h9] = 2'h0;
		rom_alu_sel[4'hA] = 2'h0;
		rom_alu_sel[4'hB] = 2'h0;
		rom_alu_sel[4'hC] = 2'h2;
		rom_alu_sel[4'hD] = 2'h2;
		rom_alu_sel[4'hE] = 2'h1;
		rom_alu_sel[4'hF] = 2'h2;
		rom_alu[5'h00] = 12'h021; // NAND, XOR, XNOR, AND, OR, NOR, ADD, ADC, SUB, SBB
		rom_alu[5'h01] = 12'h010; // X
		rom_alu[5'h02] = 12'h020; // Y
		rom_alu[5'h03] = 12'h030; // D
		rom_alu[5'h04] = 12'h330; // D, A
		rom_alu[5'h05] = 12'h331; // D, X
		rom_alu[5'h06] = 12'h332; // D, Y
		rom_alu[5'h07] = 12'h335; // D, MBR
		rom_alu[5'h08] = 12'h000; // NOP, NOT, X2
		rom_alu[5'h09] = 12'h001; // X
		rom_alu[5'h0A] = 12'h002; // Y
		rom_alu[5'h0B] = 12'h003; // D
		rom_alu[5'h0C] = 12'h300; // D, A
		rom_alu[5'h0D] = 12'h301; // D, X
		rom_alu[5'h0E] = 12'h302; // D, Y
		rom_alu[5'h0F] = 12'h305; // D, MBR
		rom_alu[5'h10] = 12'h000; // CLR, INCR, DECR
		rom_alu[5'h11] = 12'h101; // X
		rom_alu[5'h12] = 12'h202; // Y
		rom_alu[5'h13] = 12'h303; // D
		rom_alu[5'h14] = 12'h404; // DAR
		rom_alu[5'h15] = 12'h505; // MBR
		rom_alu[5'h16] = 12'h606; // RST, HOP, BOA
		rom_alu[5'h17] = 12'h707; // CLF
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
				ldi = 1'b0;
				ldv = 8'h0;
				lr = 1'b0;
				load = 1'b0;
				store = 1'b0;
				reg_src = 4'h0;
				reg_dst = 4'h0;
				mux_sel = 2'b00;
				load_en = insr_le;
			end else if (intr) begin
				{dst_f, src_b, src_a} = 12'h000;
				opcode = 4'h0;
				ldi = 1'b0;
				ldv = 8'h0;
				load = 1'b0;
				lr = 1'b0;
				store = 1'b0;
				reg_src = 4'h0;
				reg_dst = 4'h0;
				mux_sel = 2'b11;
				load_en = 1'b1;
			end else begin
				case (insr[7:4])
					4'h0, 4'h1, 4'h2, 4'h3, 4'h4, 4'h5, 4'h6, 4'h7: begin // ALU
						{dst_f, src_b, src_a} = rom_alu[{rom_alu_sel[insr[3:0]], insr[6:4]}];
						opcode = insr[3:0];
						lr = 1'b0;
						load = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b00;
						load_en = 1'b1;
						ldi = 1'b0;
						ldv = 8'h0;
					end
					4'h8, 4'h9: begin // MOV
						{dst_f, src_b, src_a} = rom_mov[insr[4:0]];
						opcode = 4'h0;
						lr = 1'b0;
						load = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b00;
						load_en = 1'b1;
						ldi = 1'b0;
						ldv = 8'h0;
					end
					4'hA: begin // JMP
						{dst_f, src_b, src_a, opcode} = rom_jmp[{insr[3:0], fval}];
						load = 1'b0;
						lr = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b00;
						load_en = 1'b1;
						ldi = 1'b0;
						ldv = 8'h0;
					end
					4'hB: begin // LD / ST
						load = ~insr[3];
						store = insr[3];
						{reg_dst, reg_src} = {2{rom_lsu[insr[2:0]]}};
						mux_sel = 2'b01;
						{dst_f, src_b, src_a} = 12'h000;
						opcode = 4'h0;
						lr = 1'b0;
						load_en = ~insr[3];
						ldi = 1'b0;
						ldv = 8'h0;
					end
					4'hC, 4'hD: begin // SHX / ROX
						{dst_f, src_b, src_a} = 12'h000;
						opcode = insr[3:0];
						lr = insr[4];
						load = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b10;
						load_en = 1'b1;
						ldi = 1'b0;
						ldv = 8'h0;
					end
					4'hE: begin // LDI
						{dst_f, src_b, src_a, opcode} = 16'h0000;
						ldi = 1'b1;
						ldv = {4'h0, insr[3:0]};
						lr = 1'b0;
						load = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						mux_sel = 2'b00;
						load_en = 1'b1;
					end
					4'hF : begin
						opcode = 4'h0;
						ldi = 1'b0;
						ldv = 8'h0;
						load = 1'b0;
						lr = 1'b0;
						store = 1'b0;
						reg_src = 4'h0;
						reg_dst = 4'h0;
						case (insr[3:0])
							4'h0: begin // DSEL
								{dst_f, src_b, src_a} = 12'h400;
								mux_sel = 2'b00;
								load_en = 1'b1;
							end
							4'h1: begin // DSET
								{dst_f, src_b, src_a} = 12'h503;
								mux_sel = 2'b00;
								load_en = 1'b1;
							end
							4'h2: begin // INTR
								{dst_f, src_b, src_a} = 12'h000;
								mux_sel = 2'b11;
								load_en = 1'b1;
							end
							4'hF: begin // HALT
								{dst_f, src_b, src_a} = 12'h000;
								mux_sel = 2'b00;
								load_en = 1'b0;
							end
							default: begin
								{dst_f, src_b, src_a} = 12'h000;
								mux_sel = 2'b00;
								load_en = 1'b0;
							end
						endcase
					end
				endcase
			end
		end else begin
			{dst_f, src_b, src_a} = 12'h000;
			opcode = 4'h0;
			ldi = 1'b0;
			ldv = 8'h0;
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