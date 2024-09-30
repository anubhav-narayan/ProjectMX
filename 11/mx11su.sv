module mx11su(
	// MX Bus Read Master Instruction
	output  wire       ins_rd_txn_start,
	 input  wire [7:0] ins_rd_data,
	 input  wire       ins_rd_ready,
	output  wire [7:0] ins_rd_addr,
	 input  wire       ins_rd_txn_ack,
	 input  wire       ins_rd_txn_cpl,

	// MX Bus Write Master Data
    output  wire       data_wr_txn_start,
    output  wire [7:0] data_wr_data,
     input  wire       data_wr_ready,
    output  wire [7:0] data_wr_addr,
     input  wire       data_wr_txn_ack,
     input  wire       data_wr_txn_cpl,
    
    // MX Bus Read Master Data
    output  wire       data_rd_txn_start,
     input  wire [7:0] data_rd_data,
     input  wire       data_rd_ready,
    output  wire [7:0] data_rd_addr,
     input  wire       data_rd_txn_ack,
     input  wire       data_rd_txn_cpl,

    // INTR
     input  wire nmi,
     input  wire irq,

	// CLK & RST
	 input  wire clk,
	 input  wire rst
);

	// Internal Wiring
	wire [15:0][7:0] reg_line;
	wire [15:0][7:0] m_data_line;
	wire [15:0][7:0] p0_data_line;
	wire [15:0][7:0] p1_data_line;
	wire [15:0][7:0] p2_data_line;
	wire [15:0][7:0] p3_data_line;
	wire [7:0] m_load_addr;
	wire [7:0] p0_load_addr;
	wire [7:0] p1_load_addr;
	wire [7:0] p2_load_addr;
	wire [7:0] p3_load_addr;
	wire [7:0] insr;
	wire       insr_le;
	wire [3:0] src_a;
	wire [3:0] src_b;
	wire [3:0] dst_f;
	wire [3:0] opcode;
	wire       ldi;
	wire [7:0] ldv;
	wire [7:0] flags;
	wire       fetch;
	wire       intr;
	wire       halt;
	wire [3:0] reg_src;
	wire [3:0] reg_dst;
	wire [7:0] biu_rd_addr;
	wire [7:0] biu_rdata;
	wire       biu_load_ready;
	wire       biu_load;
	wire       biu_load_valid;
	wire [7:0] biu_wr_addr;
	wire [7:0] biu_wdata;
	wire       biu_store_ready;
	wire       biu_store;
	wire       biu_store_valid;
	wire       load_ready;
	wire       load;
	wire       load_valid;
	wire       store_ready;
	wire       store;
	wire       store_valid;
	wire       load_en;
	wire       lr;
	wire       alu_ce_n;
	wire       bs_ce_n;
	wire [1:0] mux_sel;

	typedef enum bit[2:0] {
		RESET,
		FETCH,
		DEX,
		DLS,
		INTR,
		HALT
	} state;


	// Internal Registers
	state mstate;
	
	// Internal Wiring
	assign fetch = (mstate == FETCH);
	assign intr = (mstate == INTR);


	data_mux_4_1 #(
		.WORD_LENGTH(8),
		.DEPTH(16)
	) inst_data_mux_4_1 (
		.m_data_line  (m_data_line),
		.m_load_addr  (m_load_addr),
		.p0_data_line (p0_data_line),
		.p0_load_addr (p0_load_addr),
		.p1_data_line (p1_data_line),
		.p1_load_addr (p1_load_addr),
		.p2_data_line (p2_data_line),
		.p2_load_addr (p2_load_addr),
		.p3_data_line (p3_data_line),
		.p3_load_addr (p3_load_addr),
		.sel          (mux_sel)
	);


	reg_tap #(
		.DATA_WIDTH(8),
		.DEPTH(16)
	) inst_reg_tap (
		.data     (flags),
		.reg_line (reg_line),
		.reg_addr (4'h7)
	);


	always_ff @(posedge clk) begin
		if(rst) begin
			mstate <= RESET;
		end else begin
			case (mstate)
				RESET: begin
					// TODO: Check everything is out of reset
					mstate <= FETCH;
				end
				FETCH: begin
					if (nmi) begin
						mstate <= INTR;
					end else if (irq & flags[7]) begin
						mstate <= INTR;
					end else if (insr_le) begin
						mstate <= DEX;
					end
				end
				DEX: begin
					if (nmi) begin
						mstate <= INTR;
					end else if (load | store) begin
						mstate <= DLS;
					end else if (irq & flags[7]) begin
						mstate <= INTR;
					end else if (halt) begin
						mstate <= HALT;
					end else begin
						mstate <= FETCH;
					end
				end
				DLS: begin
					if (nmi) begin
						mstate <= INTR;
					end else if ((load_ready & load_valid) | (store_ready & store_valid)) begin
						if (irq & flags[7]) begin
							mstate <= INTR;
						end else begin
							mstate <= FETCH;
						end
					end
				end
				INTR: begin
					mstate <= FETCH;
				end
				HALT: begin
					if (nmi) begin
						mstate <= INTR;
					end else if (irq & flags[7]) begin
						mstate <= INTR;
					end
				end
				default : /* default */;
			endcase
		end
	end


	su_isa_rom inst_su_isa_rom(
		.src_a    (src_a),
		.src_b    (src_b),
		.dst_f    (dst_f),
		.opcode   (opcode),
		.ldi      (ldi),
		.ldv      (ldv),
		.load     (load),
		.store    (store),
		.reg_src  (reg_src),
		.reg_dst  (reg_dst),
		.load_en  (load_en),
		.mux_sel  (mux_sel),
		.lr       (lr),
		.alu_ce_n (alu_ce_n),
		.bs_ce_n  (bs_ce_n),
		.flags    (flags),
		.fetch    (fetch),
		.intr     (intr),
		.halt     (halt),
		.insr_le  (insr_le),
		.insr     (insr),
		.ce_n     (1'b0)
	);

	mx11_intr_ctrl inst_mx11_intr_ctrl(
		.reg_line  (reg_line),
		.data_line (p3_data_line),
		.load_addr (p3_load_addr),
		.nmi       (nmi),
		.irq       (irq),
		.intr      (intr),
		.clk       (clk),
		.rst       (rst)
	);



	mx11seu inst_mx11seu (
		.reg_line  (reg_line),
		.data_line (p0_data_line),
		.load_addr (p0_load_addr),
		.fetch     (fetch),
		.ldi       (ldi),
		.ldv       (ldv),
		.opcode    (opcode),
		.src_a     (src_a),
		.src_b     (src_b),
		.dst_f     (dst_f),
		.cs_n      (alu_ce_n)
	);


	mx11bshift inst_mx11bshift(
		.reg_line  (reg_line),
		.data_line (p2_data_line),
		.load_addr (p2_load_addr),
		.lr        (lr),
		.opcode    (opcode),
		.bs_ce_n   (bs_ce_n)
	);


	mxregs #(
		.WORD_LENGTH(8),
		.DEPTH(16)
	) inst_mxregs (
		.reg_line  (reg_line),
		.data_line (m_data_line),
		.load_addr (m_load_addr),
		.load_en   (load_en),
		.clk       (clk),
		.rst       (rst)
	);


	mxbiu_data #(
		.ADDR_WIDTH(8),
		.DATA_WIDTH(8)
	) inst_mxbiu_data (
		.m0_wr_txn_start (data_wr_txn_start),
		.m0_wr_data      (data_wr_data),
		.m0_wr_ready     (data_wr_ready),
		.m0_wr_addr      (data_wr_addr),
		.m0_wr_txn_ack   (data_wr_txn_ack),
		.m0_wr_txn_cpl   (data_wr_txn_cpl),
		.m0_rd_txn_start (data_rd_txn_start),
		.m0_rd_data      (data_rd_data),
		.m0_rd_ready     (data_rd_ready),
		.m0_rd_addr      (data_rd_addr),
		.m0_rd_txn_ack   (data_rd_txn_ack),
		.m0_rd_txn_cpl   (data_rd_txn_cpl),
		.rd_addr         (biu_rd_addr),
		.rdata           (biu_rdata),
		.load_ready      (biu_load_ready),
		.load            (biu_load),
		.load_valid      (biu_load_valid),
		.wr_addr         (biu_wr_addr),
		.wdata           (biu_wdata),
		.store_ready     (biu_store_ready),
		.store           (biu_store),
		.store_valid     (biu_store_valid),
		.clk             (clk),
		.rst             (rst)
	);


	mxlsu #(
		.ADDR_WIDTH(8),
		.DATA_WIDTH(8),
		.REGBUS_WIDTH(16)
	) inst_mxlsu (
		.biu_rd_addr     (biu_rd_addr),
		.biu_rdata       (biu_rdata),
		.biu_load_ready  (biu_load_ready),
		.biu_load        (biu_load),
		.biu_load_valid  (biu_load_valid),
		.biu_wr_addr     (biu_wr_addr),
		.biu_wdata       (biu_wdata),
		.biu_store_ready (biu_store_ready),
		.biu_store       (biu_store),
		.biu_store_valid (biu_store_valid),
		.reg_line        (reg_line),
		.data_line       (p1_data_line),
		.load_addr       (p1_load_addr),
		.addr_src        (4'h3),
		.reg_dst         (reg_dst),
		.load_ready      (load_ready),
		.load            (load),
		.load_valid      (load_valid),
		.addr_dst        (4'h3),
		.reg_src         (reg_src),
		.store_ready     (store_ready),
		.store           (store),
		.store_valid     (store_valid)
	);


	mx11_ins_fetch #(
		.ADDR_WIDTH(8),
		.DATA_WIDTH(8),
		.REGBUS_WIDTH(16)
	) inst_mx11_ins_fetch (
		.reg_line         (reg_line),
		.ins_rd_txn_start (ins_rd_txn_start),
		.ins_rd_data      (ins_rd_data),
		.ins_rd_ready     (ins_rd_ready),
		.ins_rd_addr      (ins_rd_addr),
		.ins_rd_txn_ack   (ins_rd_txn_ack),
		.ins_rd_txn_cpl   (ins_rd_txn_cpl),
		.fetch            (fetch),
		.insr             (insr),
		.load_en          (insr_le),
		.clk              (clk),
		.rst              (rst)
	);


endmodule