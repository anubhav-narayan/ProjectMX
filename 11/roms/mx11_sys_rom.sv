/*****************************************************************************
 * MX/11 Control ISA ROM
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
 * Date : 2026 - 05 - 09
 ****************************************************************************/
module mx11_sys_rom(
    // Main Read Bus Address
    output logic [3:0] m_rd_addr,
    // Auxillary Read Bus Address
    output logic [3:0] a_rd_addr,
    // Main Write Bus Address
    output logic [3:0] m_wr_addr,
    // Main Write Bus Load Enable
    output logic       m_wr_le,
    // Auxillary Write Bus Address
    output logic [3:0] a_wr_addr,
    // Auxillary Write Bus Load Enable
    output logic       a_wr_le,
    // ALU Instruction
    output logic [3:0] alu_ins,
    // Immediate Load Instruction
    output logic       ldi,
    output logic [7:0] imm8,
    // ROM Input
    input  logic [3:0] insr
);

    reg [30:0] rom [0:15];

    assign {ldi, imm8, m_rd_addr, a_rd_addr, m_wr_le, m_wr_addr, a_wr_le, a_wr_addr, alu_ins} = rom[insr];

    initial begin
        // Decode-Execute (DSEL):
        //    1. MRd <- IDEX[0x0] 	// Get source register A from RF via MRd
        //    2. IDEX <- MRd         // IDEX receives source register A value from MRd
        //    3. MWr <- IDEX(MOV, 0x5) // Process MOV in IDEX for DAR(0x5) as destination register in RF via MWr
        //    MCU Pattern: MRd:0x0 MWr:0x5 IDEX:MOV
        rom[4'h0] = {1'b0, 8'h00, 4'h0, 4'h0, 1'b1, 4'h5, 1'b0, 4'h0, 4'h0};
        // Decode-Execute (DNXT):
        //    1. MRd <- IDEX[0x5] 	// Get source register DAR from RF via MRd
        //    2. IDEX <- MRd         // IDEX receives source register A value from MRd
        //    3. MWr <- IDEX(INCR, 0x5) // Process INCR in IDEX for DAR(0x5) as destination register in RF via MWr
        //    MCU Pattern: MRd:0x5 MWr:0x5 IDEX:INCR
        rom[4'h1] = {1'b0, 8'h00, 4'h5, 4'h0, 1'b1, 4'h5, 1'b0, 4'h0, 4'h8};
        // Decode-Execute (DPRV):
        //    1. MRd <- IDEX[0x5] 	// Get source register DAR from RF via MRd
        //    2. IDEX <- MRd         // IDEX receives source register A value from MRd
        //    3. MWr <- IDEX(DECR, 0x5) // Process DECR in IDEX for DAR(0x4) as destination register in RF via MWr
        //    MCU Pattern: MRd:0x4 MWr:0x5 IDEX:DECR
        rom[4'h2] = {1'b0, 8'h00, 4'h5, 4'h0, 1'b1, 4'h5, 1'b0, 4'h0, 4'h9};
        // Decode-Execute (DRET):
        //    1. MWr <- IDEX(CLR, 0x5) // Write value 0x0 to DAR(0x4) in RF via MWr using CLR opcode in IDEX
        //    MCU Pattern: MWr:0x5,0x0 IDEX:CLR
        rom[4'h3] = {1'b0, 8'h00, 4'h0, 4'h0, 1'b1, 4'h5, 1'b0, 4'h0, 4'h1};
        // Decode-Execute (CTXS):
        //    1. MRd <- IDEX[0x7] 	// Get source register FLAGS from RF via MRd
        //    2. IDEX <- MRd        // IDEX receives source register FLAGS value from MRd
        //    3. MWr <- IDEX(OR, 0x7, imm8(0x40)) // Process OR in IDEX for FLAGS(0x7) as destination register in RF via MWr with immediate value 0x40
        //    MCU Pattern: MRd:0x7 MWr:0x7 IDEX:OR imm8:0x40
        rom[4'h4] = {1'b1, 8'h40, 4'h7, 4'h0, 1'b1, 4'h7, 1'b0, 4'h0, 4'h5};
        // Decode-Execute (CRET):
        //    1. MRd <- IDEX[0x7] 	// Get source register FLAGS from RF via MRd
        //    2. IDEX <- MRd        // IDEX receives source register FLAGS value from MRd
        //    3. MWr <- IDEX(AND, 0x7, imm8(0xBF)) // Process AND in IDEX for FLAGS(0x7) as destination register in RF via MWr with immediate value 0xBF
        //    MCU Pattern: MRd:0x7 MWr:0x7 IDEX:AND imm8:0xBF
        rom[4'h5] = {1'b1, 8'hBF, 4'h7, 4'h0, 1'b1, 4'h7, 1'b0, 4'h0, 4'h4};
        // Decode-Execute (IRQ):
        //    1. MRd <- IDEX[0x7] 	// Get source register FLAGS from RF via MRd
        //    2. IDEX <- MRd        // IDEX receives source register FLAGS value from MRd
        //    3. MWr <- IDEX(OR, 0x7, imm8(0x80)) // Process OR in IDEX for FLAGS(0x7) as destination register in RF via MWr with immediate value 0x80
        //    MCU Pattern: MRd:0x7 MWr:0x7 IDEX:OR imm8:0x80
        rom[4'h6] = {1'b1, 8'h80, 4'h7, 4'h0, 1'b1, 4'h7, 1'b0, 4'h0, 4'h5};
        // Decode-Execute (RTI):
        //    1. MRd <- IDEX[0x7] 	// Get source register FLAGS from RF via MRd
        //    2. IDEX <- MRd        // IDEX receives source register FLAGS value from MRd
        //    3. MWr <- IDEX(AND, 0x7, imm8(0x7F)) // Process AND in IDEX for FLAGS(0x7) as destination register in RF via MWr with immediate value 0x7F
        //    MCU Pattern: MRd:0x7 MWr:0x7 IDEX:AND imm8:0x7F
        rom[4'h7] = {1'b1, 8'h7F, 4'h7, 4'h0, 1'b1, 4'h7, 1'b0, 4'h0, 4'h4};
        // Decode-Execute (BRZ):
        //    1. MRd <- IDEX[0x3] 	// Get source register D from RF via MRd
        //    2. IDEX <- MRd         // IDEX receives source register A value from MRd
        //    3. MWr <- IDEX(MOV, 0x6) // Process MOV in IDEX for INSP(0x6) as destination register in RF via MWr
        //    MCU Pattern: MRd:0x0 MWr:0x6 IDEX:MOV
        rom[4'h8] = {1'b0, 8'h00, 4'h3, 4'h0, 1'b1, 4'h6, 1'b0, 4'h0, 4'h0};
        // RET
        rom[4'h9] = {1'b0, 8'h00, 4'h0, 4'h0, 1'b0, 4'h0, 1'b0, 4'h0, 4'h0};
        // Decode-Execute (SFA):
        //    1. MRd <- IDEX[0x7] 	// Get source register FLAGS from RF via MRd
        //    2. IDEX <- MRd        // IDEX receives source register FLAGS value from MRd
        //    3. ARd <- IDEX[0x0]   // Get source register A from RF via ARd
        //    2. IDEX <- ARd        // IDEX receives source register A value from ARd
        //    3. MWr <- IDEX(OR, 0x7, 0x0) // Process OR in IDEX for FLAGS(0x7) as destination register in RF via MWr with immediate value 0x40
        //    MCU Pattern: MRd:0x7 ARd:0x0 MWr:0x7 IDEX:OR
        rom[4'hA] = {1'b0, 8'h00, 4'h7, 4'h0, 1'b1, 4'h7, 1'b0, 4'h0, 4'h5};
        // Decode-Execute (LFA):
        //    1. MRd <- IDEX[0x0] 	// Get source register A from RF via MRd
        //    2. IDEX <- MRd        // IDEX receives source register A value from MRd
        //    3. MWr <- IDEX(MOV, 0x0) // Process MOV in IDEX for A(0x0) as destination register in RF via MWr
        //    MCU Pattern: MRd:0x0 ARd:0x0 MWr:0x7 IDEX:OR
        rom[4'hB] = {1'b0, 8'h00, 4'h0, 4'h0, 1'b1, 4'h7, 1'b0, 4'h0, 4'h0};
        // Decode-Execute (LD):
        //    1. MRd <- IDEX[0x3]    // Get source register D from RF via MRd
        //    2. LSU <- MRd         // LSU receives source register D value from MRd
        //    3. MWr <- LSU(LOAD, 0x04) // Process LOAD in LSU for MBR(0x4) as destination register in RF via MWr
        //    MCU Pattern: MRd:0x3 LSU:LOAD MWr:0x4
        rom[4'hC] = {1'b0, 8'h00, 4'h3, 4'h0, 1'b1, 4'h4, 1'b0, 4'h0, 4'h0};
        // Decode-Execute (ST):
        //    1. MRd <- IDEX[0x3]     // Get source register D from RF via MRd
        //    2. ARd <- IDEX[0x4]   // Get MBR from RF via ARd
        //    3. LSU <- MRd             // LSU receives source register D value from MRd
        //    4. LSU <- ARd             // LSU receives MBR value from ARd
        //    5. LSU(STORE)   // Process STORE in LSU
        //    MCU Pattern: MRd:0x3 ARd:0x4 LSU:STORE
        rom[4'hD] = {1'b0, 8'h00, 4'h3, 4'h4, 1'b0, 4'h0, 1'b0, 4'h0, 4'h0};
        // NMI
        rom[4'hE] = {1'b1, 8'h80, 4'h7, 4'h0, 1'b1, 4'h7, 1'b0, 4'h0, 4'h5};
        // HALT
        rom[4'hF] = {1'b0, 8'h00, 4'h0, 4'h0, 1'b0, 4'h0, 1'b0, 4'h0, 4'h0};
    end
    
endmodule
