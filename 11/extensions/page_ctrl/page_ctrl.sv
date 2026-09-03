module page_ctrl#(
    parameter bit [7:0] DEV_ID = 8'h01,
    parameter bit [7:0] FIRST_IPAGE = 8'hFF00
)( 
    // Page Address
    output reg [7:0] ipage,
    output reg [7:0] dpage,
	// Register Bus
	 input logic [15:0][7:0] reg_line,
	output logic [15:0][7:0] data_line,
	output logic       [7:0] load_addr,
    output logic             load_en,
    output logic             done,
	// INSR
	 input logic [7:0] insr,
    // Done
	// CLK & RST
	 input wire clk,
	 input wire rst
);
    
    wire [7:0] dar_i;
    wire [7:0] mbr_i;
    logic [7:0] dar_o;

    
    assign done = 1'b1;

	reg_tap #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) inst_reg_tap_dar (
        .data     (dar_i),
        .reg_line (reg_line),
        .reg_addr (8'h04)
    );

    reg_tap #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) inst_reg_tap_mbr (
        .data     (mbr_i),
        .reg_line (reg_line),
        .reg_addr (8'h05)
    );

    always_comb begin
        data_line = 'h0;
        load_addr = 8'h04;
        load_en = ~|(insr ^ 8'h80);
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            ipage <= FIRST_IPAGE;
            dpage <= 8'h0;
        end else begin
            if (dar_i == DEV_ID) begin
                case (insr)
                    8'h01: begin // SET IPAGE
                        ipage <= mbr_i;
                    end
                    8'h02: begin // SET DPAGE
                        dpage <= mbr_i;
                    end
                    8'h80: begin // RET
                    end
                    default: ;
                endcase
            end
        end
    end



endmodule