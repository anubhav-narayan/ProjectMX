module dma#
(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8,
	parameter integer BRST_WIDTH = 8,
	parameter integer LEN_ENT = 64
)
(
	// MX Serial Bus Read Data
    output  wire                  data_rd_txn_start,
     input  wire                  data_rd_txn_ack,
     input  wire                  data_rd_txn_cpl,
    output  wire                  data_rd_ready,
    output  wire [ADDR_WIDTH-1:0] data_rd_addr,
    output  wire [BRST_WIDTH-1:0] data_rd_burst,
     input  wire [DATA_WIDTH-1:0] data_rd_data,
     input  wire                  data_rd_valid,

	// MX Serial Bus Write Data
	output  wire                  data_wr_txn_start,
	 input  wire                  data_wr_txn_ack,
	output  wire                  data_wr_txn_cpl,
	 input  wire                  data_wr_ready,
	output  wire [ADDR_WIDTH-1:0] data_wr_addr,
    output  wire [BRST_WIDTH-1:0] data_wr_burst,
	output  wire [DATA_WIDTH-1:0] data_wr_data,
    output  wire                  data_wr_valid,

	// Memory Addressing
	 input  wire [ADDR_WIDTH-1:0] src_addr,
	 input  wire [ADDR_WIDTH-1:0] dst_addr,
	 input  wire [   LEN_ENT-1:0] t_len,

	// Control
	 input  wire               start,
	 input  wire               hold,
	output  wire               done,
	output  wire               busy,
	output  wire               rd_active,
	output  wire               wr_active,
	output  wire [LEN_ENT-1:0] rd_cntr,
	output  wire [LEN_ENT-1:0] wr_cntr,

	// CLK & RST
	 input  wire clk,
	 input  wire rst
);

	/*
	DMA Channel
	1. Latch Read and Write Buses
	2. Read from Memory Source Address
	3. Write to Memory Destination Address
	4. Repeat from 2. till length is 0
	*/
	// Internal parameter
	localparam integer MAX_DATA = DATA_WIDTH / 8;
	localparam integer MAX_BURST = 2**BRST_WIDTH;
	localparam integer MAX_PAYLOAD = MAX_DATA * MAX_BURST;
	localparam integer BASE = $clog2(MAX_DATA);

	// States
	enum reg[1:0] {
		IDLE,
		ACTIVE,
		HOLD,
		DONE
	} state;

	enum reg[2:0] {
		IDLE,
		RD_TXN_START,
		RD_TXN_ACK,
		WR_TXN_START,
		WR_TXN_ACK,
	} rd_state, wr_state;

	// Internal Registers
	reg lock;
	reg [LEN_ENT-1:0] cur_len;
	reg [BRST_WIDTH-1:0] cur_burst;
	reg [ADDR_WIDTH-1:0] cur_src_addr;
	reg [ADDR_WIDTH-1:0] cur_dst_addr;
	reg [LEN_ENT-1:0] reg_rd_cntr;
	reg [LEN_ENT-1:0] reg_wr_cntr;

	// MX Regs
	reg [ADDR_WIDTH-1:0] rd_addr_r;
	reg [ADDR_WIDTH-1:0] wr_addr_r;
	reg [DATA_WIDTH-1:0] rd_data_r;
	reg [DATA_WIDTH-1:0] wr_data_r;
	reg [BRST_WIDTH-1:0] rd_burst_r;
	reg [BRST_WIDTH-1:0] wr_burst_r;
	reg                  rd_valid_r;
	reg                  wr_valid_r;
	reg                  rd_txn_start;
	reg                  wr_txn_start;
	reg                  rd_txn_cpl;
	reg                  wr_txn_cpl;

	assign done = (state == DONE);
	assign busy = (state == ACTIVE);

	always @(*) begin
		lock <= start;
	end

	// Counters
	always_ff @(posedge clk) begin
		if(rst) begin
			reg_rd_cntr <= 'h0;
			reg_wr_cntr <= 'h0;
		end else begin
			if (state == ACTIVE) begin
				if (data_wr_valid) begin
					reg_wr_cntr <= reg_wr_cntr + cur_len > MAX_DATA ? MAX_DATA : ;
				end
				if (data_rd_valid) begin
					reg_rd_cntr <= reg_rd_cntr + MAX_DATA;
				end
			end
		end
	end

	// AGU
	always_ff @(posedge clk) begin
		if(rst) begin
			/*
				Reset all registers to 0 
			*/
			state <= IDLE;
			cur_src_addr <= 'h0;
			cur_dst_addr <= 'h0;
			cur_len <= 'h0;
			cur_burst <= 'h0;
		end else begin
			case (state)
				IDLE: begin
					/*
						In IDLE, chekc for t_len,
						If t_len > 0 then proceed to check for control
						signals start and hold
					*/
					if (t_len) begin
						cur_len <= t_len;
						cur_src_addr <= src_addr;
						cur_dst_addr <= dst_addr;
						cur_burst <= (t_len) > MAX_PAYLOAD ? MAX_BURST - 'h1 : (t_len - 'h 1)[BASE+:BRST_WIDTH];
						if (start & hold) begin
							state <= HOLD;
						end else if (start) begin
							state <= ACTIVE;
						end
					end
				end
				ACTIVE: begin
					if (hold) begin
						state <= HOLD;
					end else begin
						if (data_wr_valid) begin
							cur_len <= (cur_len > MAX_DATA ? cur_len - MAX_DATA : 'h0);
						end
						if (data_wr_txn_cpl & ~|cur_len) begin
							state <= DONE;
						end else if (data_wr_txn_cpl) begin
							cur_burst <= (cur_len) > MAX_PAYLOAD ? MAX_BURST - 'h1 : (cur_len - 'h 1)[BASE+:BRST_WIDTH] + |cur_len[BASE-1:0];
							cur_src_addr <= cur_src_addr + MAX_PAYLOAD;
							cur_dst_addr <= cur_dst_addr + MAX_PAYLOAD;
						end
					end
				end
				HOLD: begin
					if (~hold) begin
						state <= ACTIVE;
					end
				end
				DONE: begin
					if (~lock) begin
						state <= IDLE;
					end
				end
			endcase
		end
	end

	sync_txn_pipe #(
		.DEPTH(MAX_BURST),
		.DATA_WIDTH(DATA_WIDTH+1)
	) inst_sync_txn_pipe (
		.data_in_ready  (data_rd_ready),
		.data_in_data   ({data_rd_txn_cpl, data_rd_data}),
		.data_in_valid  (data_rd_valid),
		.data_out_ready (data_wr_ready),
		.data_out_data  ({data_wr_txn_cpl, data_wr_data}),
		.data_out_valid (data_wr_valid),
		.clk            (clk),
		.rst            (rst)
	);


	always_ff @(posedge clk) begin
		if(rst) begin
			rd_state <= IDLE;
			rd_txn_start <= 1'b0;
			rd_data_r <= 'h0;
			rd_valid_r <= 'h0;
			rd_txn_cpl <= 1'b0;
			rd_addr_r <= 'h0;
			rd_burst_r <= 'h0;
		end else begin
			case (rd_state)
				IDLE: begin
					if (data_rd_ready & rd_start) begin
						rd_txn_start <= 1'b1;
						rd_addr_r <= cur_src_addr;
						rd_burst_r <= cur_burst;
						rd_state <= RD_TXN_START;
					end
				end
				RD_TXN_START: begin
					if (data_rd_txn_ack & ~data_rd_txn_cpl) begin
						rd_txn_start <= 1'b0;
						rd_state <= RD_TXN_ACK;
					end else if (data_rd_txn_ack & data_rd_txn_cpl) begin
						rd_txn_start <= 1'b0;
						rd_state <= IDLE;
					end
				end
				RD_TXN_ACK: begin
					if (data_rd_txn_cpl) begin
						rd_state <= IDLE;
					end
				end
			endcase
		end
	end

	always_ff @(posedge clk) begin
		if(rst) begin
			wr_state <= IDLE;
			wr_txn_start <= 1'b0;
			wr_data_r <= 'h0;
			wr_valid_r <= 'h0;
			wr_txn_cpl <= 1'b0;
			wr_addr_r <= 'h0;
			wr_burst_r <= 'h0;
		end else begin
			case (wr_state)
				IDLE: begin
					if (data_wr_ready & wr_start) begin
						wr_txn_start <= 1'b1;
						wr_addr_r <= cur_src_addr;
						wr_burst_r <= cur_burst;
						wr_state <= WR_TXN_START;
					end
				end
				WR_TXN_START: begin
					if (data_wr_txn_ack & ~data_wr_txn_cpl) begin
						wr_txn_start <= 1'b0;
						wr_state <= WR_TXN_ACK;
					end else if (data_wr_txn_ack & data_wr_txn_cpl) begin
						wr_txn_start <= 1'b0;
						wr_state <= IDLE;
					end
				end
				WR_TXN_ACK: begin
					if (data_wr_txn_cpl) begin
						wr_state <= IDLE;
					end
				end
			endcase
		end
	end

endmodule


module sync_txn_pipe#(
	parameter integer DEPTH = 8,
	parameter integer DATA_WIDTH = 8
)
(
    // Input
    output  wire                  data_in_ready,
     input  wire [DATA_WIDTH-1:0] data_in_data,
     input  wire                  data_in_valid,

    // Output
	 input  wire                  data_out_ready,
	output   reg [DATA_WIDTH-1:0] data_out_data,
    output   reg                  data_out_valid,

    // CLK & RST
	 input  wire clk,
	 input  wire rst
);

	// Internals
	reg [DEPTH-1:0][DATA_WIDTH-1:0] sync_data;
	reg [DEPTH-1:0] sync_valid;

	assign data_in_ready = data_out_ready;

	always_ff @(posedge clk) begin
		if (rst) begin
			sync_valid <= 'h0;
		end else begin
			if (data_in_ready & data_in_valid) begin
				sync_valid[0] <= data_in_valid;
				sync_data[0] <= data_in_data;
			end else begin
				sync_data[0] <= 'h0;
				sync_valid[0] <= 1'b0;
			end
			if (data_out_ready) begin
				for (integer i = 0; i < DEPTH-1; i++) begin
					sync_valid[i+1] <= sync_valid[i];
					sync_data[i+1] <= sync_data[i];
				end
			end
			if (data_out_ready) begin
				data_out_data <= sync_data[DEPTH-1];
				data_out_valid <= sync_valid[DEPTH-1];
			end else begin
				data_out_data <= 'h0;
				data_out_valid <= 1'b0;
			end
		end
	end


endmodule