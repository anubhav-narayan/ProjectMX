module mx11_ins_fetch#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8,
	parameter integer REGBUS_WIDTH = 16
)(
	// Register Bus
	 input wire [REGBUS_WIDTH-1:0][DATA_WIDTH-1:0] reg_line,

	// MX Bus Read Master
	output  wire                  ins_rd_txn_start,
	 input  wire [DATA_WIDTH-1:0] ins_rd_data,
	 input  wire                  ins_rd_ready,
	output  wire [ADDR_WIDTH-1:0] ins_rd_addr,
	 input  wire                  ins_rd_txn_ack,
	 input  wire                  ins_rd_txn_cpl,

	// Control
	 input  wire                  fetch,
	output  wire [DATA_WIDTH-1:0] insr,
	output  wire                  load_en,

	// CLK & RST
	 input  wire clk,
	 input  wire rst
);

	wire [DATA_WIDTH-1:0] insp;

	reg_tap #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(REGBUS_WIDTH)
	) inst_reg_tap (
		.data     (insp),
		.reg_line (reg_line),
		.reg_addr (4'h6)
	);

	mxbiu_ins #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) inst_mxbiu_ins (
		.m0_rd_txn_start (ins_rd_txn_start),
		.m0_rd_data      (ins_rd_data),
		.m0_rd_ready     (ins_rd_ready),
		.m0_rd_addr      (ins_rd_addr),
		.m0_rd_txn_ack   (ins_rd_txn_ack),
		.m0_rd_txn_cpl   (ins_rd_txn_cpl),
		.insp            (insp),
		.ce_n            (~fetch),
		.insr            (insr),
		.valid           (load_en),
		.clk             (clk),
		.rst             (rst)
	);

endmodule