module data_mux_4_1#(
    parameter WORD_LENGTH = 8,
    parameter DEPTH = 16
)(
	// Master
	output logic [DEPTH-1:0][WORD_LENGTH-1:0] m_data_line,
	output logic            [            7:0] m_load_addr,
	output logic                              m_load_en,

	// Port 0
	 input  wire [DEPTH-1:0][WORD_LENGTH-1:0] p0_data_line,
	 input  wire            [            7:0] p0_load_addr,
	 input  wire                              p0_load_en,

	// Port 1
	 input  wire [DEPTH-1:0][WORD_LENGTH-1:0] p1_data_line,
	 input  wire            [            7:0] p1_load_addr,
	 input  wire                              p1_load_en,

	// Port 2
	 input  wire [DEPTH-1:0][WORD_LENGTH-1:0] p2_data_line,
	 input  wire            [            7:0] p2_load_addr,
	 input  wire                              p2_load_en,

	// Port 3
	 input  wire [DEPTH-1:0][WORD_LENGTH-1:0] p3_data_line,
	 input  wire            [            7:0] p3_load_addr,
	 input  wire                              p3_load_en,

	// Selection
	 input  wire [1:0] sel

);

	always_comb begin
		case (sel)
			2'b00: begin
				m_data_line = p0_data_line;
				m_load_addr = p0_load_addr;
				m_load_en = p0_load_en;
			end
			2'b01: begin
				m_data_line = p1_data_line;
				m_load_addr = p1_load_addr;
				m_load_en = p1_load_en;
			end
			2'b10: begin
				m_data_line = p2_data_line;
				m_load_addr = p2_load_addr;
				m_load_en = p2_load_en;
			end
			2'b11: begin
				m_data_line = p3_data_line;
				m_load_addr = p3_load_addr;
				m_load_en = p3_load_en;
			end
		endcase
	end

endmodule

module wr_mux_2_1#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
	// Master
	output wire [ADDR_WIDTH-1:0] m_wr_addr,
	output wire [DATA_WIDTH-1:0] m_wr_data,
	output wire                  m_wr_le,

	// Port 0
	 input wire [ADDR_WIDTH-1:0] p0_wr_addr,
	 input wire [DATA_WIDTH-1:0] p0_wr_data,
	 input wire                  p0_wr_le,

	// Port 1
	 input wire [ADDR_WIDTH-1:0] p1_wr_addr,
	 input wire [DATA_WIDTH-1:0] p1_wr_data,
	 input wire                  p1_wr_le,

	// Selection
	 input wire sel

);
	
	assign m_wr_addr = sel ? p1_wr_addr : p0_wr_addr;
	assign m_wr_data = sel ? p1_wr_data : p0_wr_data;
	assign m_wr_le = sel ? p1_wr_le : p0_wr_le;

endmodule

module rd_mux_2_1#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
	// Master
	output wire [ADDR_WIDTH-1:0] m_rd_addr,
	 input wire [DATA_WIDTH-1:0] m_rd_data,
	// Port 0
	 input wire [ADDR_WIDTH-1:0] p0_rd_addr,
	output wire [DATA_WIDTH-1:0] p0_rd_data,

	// Port 1
	 input wire [ADDR_WIDTH-1:0] p1_rd_addr,
	output wire [DATA_WIDTH-1:0] p1_rd_data,

	// Selection
	 input wire sel

);
	
	assign m_rd_addr = sel ? p1_rd_addr : p0_rd_addr;
	assign {p1_rd_data, p0_rd_data} = {2{m_rd_data}};

endmodule