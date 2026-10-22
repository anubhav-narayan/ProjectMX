module seu11_rom #(
    parameter ROM_FILE = "./alu11/seu.hex"
) (
    input  logic [7:0] insr,

    output logic       ldi,
    output logic [7:0] imm8,
    output logic [3:0] m_rd_addr,
    output logic [3:0] a_rd_addr,
    output logic       m_wr_le,
    output logic [3:0] m_wr_addr,
    output logic       a_wr_le,
    output logic [3:0] a_wr_addr,
    output logic [3:0] alu_ins
);

    logic [30:0] rom [0:255];

    assign {
        ldi,
        imm8,
        m_rd_addr,
        a_rd_addr,
        m_wr_le,
        m_wr_addr,
        a_wr_le,
        a_wr_addr,
        alu_ins
    } = rom[insr];

    initial begin
        $readmemh(ROM_FILE, rom);
    end

endmodule