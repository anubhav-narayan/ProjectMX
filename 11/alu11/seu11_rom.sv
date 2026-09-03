module mx11_seu_rom(
    // Main Read Bus Address
    output logic [3:0] m_rd_addr,
    // Auxillary Read Bus Address
    output logic [3:0] a_rd_addr,
    // Main Write Bus Address
    output logic [3:0] m_wr_addr,
    // Auxillary Write Bus Address
    output logic [3:0] a_wr_addr,
    // ALU Instruction
    output logic [3:0] alu_ins,
    // Immediate Load Instruction
    output logic       ldi,
    output logic [7:0] imm8,
    // ROM Input
    input  logic [7:0] insr
);

    reg [28:0] rom_mov [0:127];

    assign {ldi, imm8, m_rd_addr, a_rd_addr, m_wr_addr, a_wr_addr, alu_ins} = rom_mov[insr];

    initial begin
    // Decode-Execute (Data Movement Class):
	//     1. MRd <- IDEX[INSR[3:0]]      // Get source register from RF via MRd using INSR[3:0] as address
	//     2. IDEX <- MRd                 // IDEX receives source register value from MRd
	//     3. MWr <- IDEX(MOV, INSR[6:4]) // Process MOV in IDEX for INSR[6:4] as destination register
	//     MCU Pattern: MRd:INSR[3:0] MWr:INSR[6:4] IDEX:MOV
    rom_mov[8'h00] = 29'h00000000; // NOP | MOV A, A
    rom_mov[8'h01] = 29'h00000000; // MOV A, X
    end

endmodule : mx11_seu_rom