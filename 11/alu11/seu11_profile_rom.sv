module seu11_profile_rom #(
    parameter ROM_FILE = "./alu11/seu.hex"
) (
    input  logic       clk,
    input  logic [7:0] insr,
    input  logic       use_profile,
    input  logic       profile_wr_en,
    input  logic [7:0] profile_wr_addr,
    input  logic [30:0] profile_wr_data,

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

    logic       default_ldi;
    logic [7:0] default_imm8;
    logic [3:0] default_m_rd_addr;
    logic [3:0] default_a_rd_addr;
    logic       default_m_wr_le;
    logic [3:0] default_m_wr_addr;
    logic       default_a_wr_le;
    logic [3:0] default_a_wr_addr;
    logic [3:0] default_alu_ins;
    logic [30:0] profile_words [0:255];
    logic [30:0] selected_word;

    seu11_rom #(
        .ROM_FILE(ROM_FILE)
    ) default_rom (
        .insr(insr),
        .ldi(default_ldi),
        .imm8(default_imm8),
        .m_rd_addr(default_m_rd_addr),
        .a_rd_addr(default_a_rd_addr),
        .m_wr_le(default_m_wr_le),
        .m_wr_addr(default_m_wr_addr),
        .a_wr_le(default_a_wr_le),
        .a_wr_addr(default_a_wr_addr),
        .alu_ins(default_alu_ins)
    );

    always_ff @(posedge clk) begin
        if (profile_wr_en) begin
            profile_words[profile_wr_addr] <= profile_wr_data;
        end
    end

    assign selected_word = use_profile
        ? profile_words[insr]
        : {
            default_ldi,
            default_imm8,
            default_m_rd_addr,
            default_a_rd_addr,
            default_m_wr_le,
            default_m_wr_addr,
            default_a_wr_le,
            default_a_wr_addr,
            default_alu_ins
        };

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
    } = selected_word;

endmodule
