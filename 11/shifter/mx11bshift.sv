module mx11bshift (
	// Register Bus
	 input logic [15:0][7:0] reg_line,
	output logic [15:0][7:0] data_line,
	output logic       [7:0] load_addr,
	// OPS
	input logic             lr,
	input logic       [3:0] opcode,
	input logic             bs_ce_n
);

	wire [7:0] out;
	wire [7:0] data;

	assign load_addr = 8'h00;
	
	reg_tap #(
		.DATA_WIDTH(8),
		.DEPTH(16)
	) inst_reg_tap (
		.data     (data),
		.reg_line (reg_line),
		.reg_addr (4'h0)
	);

	always_comb begin
		for (int i = 0; i < 16; i++) begin
			data_line[i] = out;
		end
	end

	barrel_shift_8bit inst_barrel_shift_8bit(
		.en(~bs_ce_n),
		.lr(lr),
		.rot(opcode[3]),
		.data(data),
		.shift(opcode[2:0]),
		.out(out)
	);

endmodule

module barrel_shift_8bit (
	input wire en, 
	input wire lr, 
	input wire rot, 
	input[7:0] data,
	input[2:0] shift,
	output[7:0] out
);
wire[7:0] x, y, z, dsel, xsel, ysel;

assign dsel = lr ? (rot ? {data[3:0], data[7:4]} : {4'b0, data[7:4]}) : (rot ? {data[3:0], data[7:4]} : {data[3:0], 4'b0});
// 4-bit Shift Right
assign x[7] = shift[2]?dsel[7]:data[7];
assign x[6] = shift[2]?dsel[6]:data[6];
assign x[5] = shift[2]?dsel[5]:data[5];
assign x[4] = shift[2]?dsel[4]:data[4];
assign x[3] = shift[2]?dsel[3]:data[3];
assign x[2] = shift[2]?dsel[2]:data[2];
assign x[1] = shift[2]?dsel[1]:data[1];
assign x[0] = shift[2]?dsel[0]:data[0];

assign xsel = lr ? (rot ? {x[1:0], x[7:2]} : {2'b0, x[7:2]}) : (rot ? {x[5:0], x[7:6]} : {x[5:0], 2'b0});
// 2-bit Shift Right
assign y[7] = shift[1]?xsel[7]:x[7];
assign y[6] = shift[1]?xsel[6]:x[6];
assign y[5] = shift[1]?xsel[5]:x[5];
assign y[4] = shift[1]?xsel[4]:x[4];
assign y[3] = shift[1]?xsel[3]:x[3];
assign y[2] = shift[1]?xsel[2]:x[2];
assign y[1] = shift[1]?xsel[1]:x[1];
assign y[0] = shift[1]?xsel[0]:x[0];

assign ysel = lr ? (rot ? {y[0], y[7:1]} : {1'b0, y[7:1]}) : (rot ? {y[6:0], y[7]} : {y[6:0], 1'b0});
// 1-bit Shift Right
assign z[7] = shift[0]?ysel[7]:y[7];
assign z[6] = shift[0]?ysel[6]:y[6];
assign z[5] = shift[0]?ysel[5]:y[5];
assign z[4] = shift[0]?ysel[4]:y[4];
assign z[3] = shift[0]?ysel[3]:y[3];
assign z[2] = shift[0]?ysel[2]:y[2];
assign z[1] = shift[0]?ysel[1]:y[1];
assign z[0] = shift[0]?ysel[0]:y[0];

assign out = en ? z : data;

endmodule