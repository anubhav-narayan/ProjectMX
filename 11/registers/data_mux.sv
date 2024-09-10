module data_mux_4_1#(
    parameter WORD_LENGTH = 8,
    parameter DEPTH = 16
)(
	// Master
	output logic [DEPTH-1:0][WORD_LENGTH-1:0] m_data_line,
	output logic            [            7:0] m_load_addr,

	// Port 0
	 input  wire [DEPTH-1:0][WORD_LENGTH-1:0] p0_data_line,
	 input  wire            [            7:0] p0_load_addr,

	// Port 1
	 input  wire [DEPTH-1:0][WORD_LENGTH-1:0] p1_data_line,
	 input  wire            [            7:0] p1_load_addr,

	// Port 2
	 input  wire [DEPTH-1:0][WORD_LENGTH-1:0] p2_data_line,
	 input  wire            [            7:0] p2_load_addr,

	// Port 3
	 input  wire [DEPTH-1:0][WORD_LENGTH-1:0] p3_data_line,
	 input  wire            [            7:0] p3_load_addr,

	// Selection
	 input  wire [1:0] sel

);

	always_comb begin
		case (sel)
			2'b00: begin
				m_data_line = p0_data_line;
				m_load_addr = p0_load_addr;
			end
			2'b01: begin
				m_data_line = p1_data_line;
				m_load_addr = p1_load_addr;
			end
			2'b10: begin
				m_data_line = p2_data_line;
				m_load_addr = p2_load_addr;
			end
			2'b11: begin
				m_data_line = p3_data_line;
				m_load_addr = p3_load_addr;
			end
		endcase
	end

endmodule

module data_mux_2_1#(
    parameter WORD_LENGTH = 8,
    parameter DEPTH = 16
)(
	// Master
	output wire [DEPTH-1:0][WORD_LENGTH-1:0] m_data_line,
	output wire            [            7:0] m_load_addr,

	// Port 0
	 input wire [DEPTH-1:0][WORD_LENGTH-1:0] p0_data_line,
	 input wire            [            7:0] p0_load_addr,

	// Port 1
	 input wire [DEPTH-1:0][WORD_LENGTH-1:0] p1_data_line,
	 input wire            [            7:0] p1_load_addr,

	// Selection
	 input wire sel

);

	
	assign m_data_line = sel ? p1_data_line : p0_data_line;
	assign m_load_addr = sel ? p1_load_addr : p0_load_addr;


endmodule