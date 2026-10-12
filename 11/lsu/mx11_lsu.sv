module mx11_lsu#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8
)(
	// MX Bus Read Manager
	output  wire                  data_rd_txn_start,
	 input  wire                  data_rd_txn_ack,
	 input  wire                  data_rd_txn_cpl,
	output  wire [ADDR_WIDTH-1:0] data_rd_addr,
	 input  wire [DATA_WIDTH-1:0] data_rd_data,
	 input  wire                  data_rd_ready,
	// MX Bus Write Manager
	output  wire                  data_wr_txn_start,
	 input  wire                  data_wr_txn_ack,
	 input  wire                  data_wr_txn_cpl,
	output  wire [ADDR_WIDTH-1:0] data_wr_addr,
	output  wire [DATA_WIDTH-1:0] data_wr_data,
	 input  wire                  data_wr_ready,

	// Read Control
	 input  wire [ADDR_WIDTH-1:0] rd_addr,
	output  wire [DATA_WIDTH-1:0] rdata,
	output  wire                  load_ready,
	 input  wire                  load,
	output  wire                  load_valid,
	// Write Control
	 input  wire [ADDR_WIDTH-1:0] wr_addr,
	 input  wire [DATA_WIDTH-1:0] wdata,
	output  wire                  store_ready,
	 input  wire                  store,
	output  wire                  store_valid,
	
	// CLK & RST
	 input  wire clk,
	 input  wire rst
);

	mxbiu_data #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) inst_mxbiu_data (
		.m0_wr_txn_start(data_wr_txn_start),
		.m0_wr_data(data_wr_data),
		.m0_wr_ready(data_wr_ready),
		.m0_wr_addr(data_wr_addr),
		.m0_wr_txn_ack(data_wr_txn_ack),
		.m0_wr_txn_cpl(data_wr_txn_cpl),

		.m0_rd_txn_start(data_rd_txn_start),
		.m0_rd_data(data_rd_data),
		.m0_rd_ready(data_rd_ready),
		.m0_rd_addr(data_rd_addr),
		.m0_rd_txn_ack(data_rd_txn_ack),
		.m0_rd_txn_cpl(data_rd_txn_cpl),

		.rd_addr(rd_addr),
		.rdata(rdata),
		.load_ready(load_ready),
		.load(load),
		.load_valid(load_valid),

		.wr_addr(wr_addr),
		.wdata(wdata),
		.store_ready(store_ready),
		.store(store),
		.store_valid(store_valid),

		.clk(clk),
		.rst(rst)
	);


endmodule