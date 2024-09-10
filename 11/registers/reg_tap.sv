module reg_tap#(
	parameter integer DATA_WIDTH = 8,
	parameter integer DEPTH = 16
)(
	output   reg            [DATA_WIDTH-1:0] data,
	 input  wire [DEPTH-1:0][DATA_WIDTH-1:0] reg_line,
	 input  wire         [$clog2(DEPTH)-1:0] reg_addr
);

	always_comb begin
		data = reg_line[reg_addr];
	end

endmodule