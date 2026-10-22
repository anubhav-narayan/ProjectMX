module page_ctrl#(
    parameter RESET_PAGE = 8'h00
)(
    // MX/11 register-file read buses: main selects DAR, auxiliary selects MBR.
    output logic [3:0] m_rd_addr,
    input  logic [7:0] m_rd_data,

    // Page state and extension ISA
    output logic [7:0] ipage,
    output logic [7:0] dpage,
    input  logic [7:0] insr,
    input  logic       ex_ce,

    // Interrupt
    input  logic       irq,
    input  logic       nmi,

    // CLK and Reset
    input  logic       clk,
    input  logic       rst
);

/*
MNEMONIC | OPCODE | DESCRIPTION
---------+--------+---------------------------------------------------
SET IPAGE, reg | 0x00-0x0F | Set the instruction page to the value in the specified register.
SET DPAGE, reg | 0x10-0x1F | Set the data page to the value in the specified register.
SET IRQPAGE, reg | 0x20-0x2F | Set the interrupt request page to the value in the specified register.
SET NMIPAGE, reg | 0x30-0x3F | Set the non-maskable interrupt page to the value in the specified register. 
*/

    reg [7:0] ipage_r, dpage_r, irqpage_r, nmipage_r;

    assign m_rd_addr = insr[3:0];
    assign ipage = nmi ? nmipage_r : irq ? irqpage_r : ipage_r;
    assign dpage = dpage_r;

    always_ff @(posedge clk) begin
        if (rst) begin
            ipage_r <= RESET_PAGE;
            dpage_r <= RESET_PAGE;
            irqpage_r <= RESET_PAGE;
            nmipage_r <= RESET_PAGE;
        end else begin
            case (insr[7:4])
                4'h0: ipage_r <= m_rd_data; // SET IPAGE, reg
                4'h1: dpage_r <= m_rd_data; // SET DPAGE, reg
                4'h2: irqpage_r <= m_rd_data; // SET IRQPAGE, reg
                4'h3: nmipage_r <= m_rd_data; // SET NMIPAGE, reg
                default: begin end
            endcase
        end
    end

    

endmodule
