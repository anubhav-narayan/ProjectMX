module mxlsu#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8,
	parameter integer REGBUS_WIDTH = 16
)(
	// BIU Signals
    output logic [ADDR_WIDTH-1:0] biu_rd_addr,
	 input logic [DATA_WIDTH-1:0] biu_rdata,
	 input logic                  biu_load_ready,
	output logic                  biu_load,
	 input logic                  biu_load_valid,
    output logic [ADDR_WIDTH-1:0] biu_wr_addr,
	output logic [DATA_WIDTH-1:0] biu_wdata,
	 input logic                  biu_store_ready,
	output logic                  biu_store,
	 input logic                  biu_store_valid,

	// Register Bus
	 input logic [REGBUS_WIDTH-1:0][7:0] reg_line,
	output logic [REGBUS_WIDTH-1:0][7:0] data_line,
	output logic                   [7:0] load_addr,

	// Control
	 input logic [$clog2(REGBUS_WIDTH)-1:0] addr_src,
	 input logic [$clog2(REGBUS_WIDTH)-1:0] reg_dst,
	output logic                            load_ready,
	 input logic                            load,
	output logic                            load_valid,
	 input logic [$clog2(REGBUS_WIDTH)-1:0] addr_dst,
	 input logic [$clog2(REGBUS_WIDTH)-1:0] reg_src,
	output logic                            store_ready,
	 input logic                            store,
	output logic                            store_valid
);

	assign biu_load = load;
	assign load_valid = biu_load_valid;
	assign load_ready = biu_load_ready;
	assign biu_store = store;
	assign store_valid = biu_store_valid;
	assign store_ready = biu_store_ready;


	reg_tap #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(REGBUS_WIDTH)
	) inst_reg_tap_wdata (
		.data     (biu_wdata),
		.reg_line (reg_line),
		.reg_addr (reg_src)
	);

	reg_tap #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(REGBUS_WIDTH)
	) inst_reg_tap_wraddr (
		.data     (biu_wr_addr),
		.reg_line (reg_line),
		.reg_addr (addr_dst)
	);

	reg_tap #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(REGBUS_WIDTH)
	) inst_reg_tap_rdaddr (
		.data     (biu_rd_addr),
		.reg_line (reg_line),
		.reg_addr (addr_src)
	);

	assign load_addr = {4'h0, reg_dst};

	always_comb begin
		for (int i = 0; i < REGBUS_WIDTH; i++) begin
			data_line[i] = biu_rdata;
		end
	end

endmodule