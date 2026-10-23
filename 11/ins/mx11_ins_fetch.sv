module mx11_ins_fetch(
	// Register Bus
	 input wire [7:0] insp,

	// MX Bus Read Master
	output  wire       ins_rd_txn_start,
	 input  wire [7:0] ins_rd_data,
	 input  wire       ins_rd_ready,
	output  wire [7:0] ins_rd_addr,
	 input  wire       ins_rd_txn_ack,
	 input  wire       ins_rd_txn_cpl,

	// Control
	 input  wire       fetch,
	output  wire [7:0] insr,
	output  wire       fetch_done,

	// CLK & RST
	 input  wire clk,
	 input  wire rst
);

	reg [7:0] insp_r;
	reg fetch_r;

	always_ff @(posedge clk) begin
		if (rst) begin
			insp_r <= 8'h0;
			fetch_r <= 1'b0;
		end else begin
			if (fetch) begin
				insp_r <= insp;
			end
			fetch_r <= fetch;
		end
	end
	
	mxbiu_ins #(
		.ADDR_WIDTH(8),
		.DATA_WIDTH(8)
	) inst_mxbiu_ins (
		.m0_rd_txn_start (ins_rd_txn_start),
		.m0_rd_data      (ins_rd_data),
		.m0_rd_ready     (ins_rd_ready),
		.m0_rd_addr      (ins_rd_addr),
		.m0_rd_txn_ack   (ins_rd_txn_ack),
		.m0_rd_txn_cpl   (ins_rd_txn_cpl),
		.insp            (insp_r),
		.get_ins         (fetch_r),
		.insr            (insr),
		.valid           (fetch_done),
		.clk             (clk),
		.rst             (rst)
	);

endmodule