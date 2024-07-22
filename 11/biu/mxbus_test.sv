module mxbus_test_ins#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8
)(
	// Internal Signal
	 input wire [ADDR_WIDTH-1:0] insp,
	 input wire                  ce_n,
	output wire [DATA_WIDTH-1:0] insr,
	output wire                  valid,

	// CLK & RST
	 input  wire clk,
	 input  wire rst
);

	
	wire                  rd_txn_start;
	wire [DATA_WIDTH-1:0] rd_data;
	wire                  rd_ready;
	wire [ADDR_WIDTH-1:0] rd_addr;
	wire                  rd_txn_ack;
	wire                  rd_txn_cpl;


	mxbiu_ins #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) inst_mxbiu_ins (
		.m0_rd_txn_start (rd_txn_start),
		.m0_rd_data      (rd_data),
		.m0_rd_ready     (rd_ready),
		.m0_rd_addr      (rd_addr),
		.m0_rd_txn_ack   (rd_txn_ack),
		.m0_rd_txn_cpl   (rd_txn_cpl),
		.insp            (insp),
		.ce_n            (ce_n),
		.insr            (insr),
		.valid           (valid),
		.clk             (clk),
		.rst             (rst)
	);


	mxbus_rom #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) inst_mxbus_rom (
		.s0_rd_txn_start (rd_txn_start),
		.s0_rd_data      (rd_data),
		.s0_rd_ready     (rd_ready),
		.s0_rd_addr      (rd_addr),
		.s0_rd_txn_ack   (rd_txn_ack),
		.s0_rd_txn_cpl   (rd_txn_cpl),
		.clk             (clk),
		.rst             (rst)
	);


endmodule


module mxbus_test_data#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8
)(
	// Internal Signal
	 input wire [ADDR_WIDTH-1:0] mar,
	 input wire                  load,
	 input wire                  store,
	 input wire [DATA_WIDTH-1:0] mbr_in,
	output wire [DATA_WIDTH-1:0] mbr_out,
	output wire                  load_valid,
	output wire                  store_valid,

	// CLK & RST
	 input  wire clk,
	 input  wire rst
);

	
	// MX Bus Write Master
    wire                  wr_txn_start;
    wire [DATA_WIDTH-1:0] wr_data;
    wire                  wr_ready;
    wire [ADDR_WIDTH-1:0] wr_addr;
    wire                  wr_txn_ack;
    wire                  wr_txn_cpl;
    
    // MX Bus Read Master
    wire                  rd_txn_start;
    wire [DATA_WIDTH-1:0] rd_data;
    wire                  rd_ready;
    wire [ADDR_WIDTH-1:0] rd_addr;
    wire                  rd_txn_ack;
    wire                  rd_txn_cpl;
	

	mxbus_ram #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) inst_mxbus_ram (
		.s0_wr_txn_start (wr_txn_start),
		.s0_wr_data      (wr_data),
		.s0_wr_ready     (wr_ready),
		.s0_wr_addr      (wr_addr),
		.s0_wr_txn_ack   (wr_txn_ack),
		.s0_wr_txn_cpl   (wr_txn_cpl),
		.s0_rd_txn_start (rd_txn_start),
		.s0_rd_data      (rd_data),
		.s0_rd_ready     (rd_ready),
		.s0_rd_addr      (rd_addr),
		.s0_rd_txn_ack   (rd_txn_ack),
		.s0_rd_txn_cpl   (rd_txn_cpl),
		.clk             (clk),
		.rst             (rst)
	);

	mxbiu_data #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) inst_mxbiu_data (
		.m0_wr_txn_start (wr_txn_start),
		.m0_wr_data      (wr_data),
		.m0_wr_ready     (wr_ready),
		.m0_wr_addr      (wr_addr),
		.m0_wr_txn_ack   (wr_txn_ack),
		.m0_wr_txn_cpl   (wr_txn_cpl),
		.m0_rd_txn_start (rd_txn_start),
		.m0_rd_data      (rd_data),
		.m0_rd_ready     (rd_ready),
		.m0_rd_addr      (rd_addr),
		.m0_rd_txn_ack   (rd_txn_ack),
		.m0_rd_txn_cpl   (rd_txn_cpl),
		.mar             (mar),
		.load            (load),
		.store           (store),
		.mbr_in          (mbr_in),
		.mbr_out         (mbr_out),
		.load_valid      (load_valid),
		.store_valid     (store_valid),
		.clk             (clk),
		.rst             (rst)
	);


endmodule