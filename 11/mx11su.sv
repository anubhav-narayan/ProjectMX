module mx11su(
	// MX Bus Read Master Instruction
	output  wire       ins_rd_txn_start,
	 input  wire [7:0] ins_rd_data,
	 input  wire       ins_rd_ready,
	output  wire [7:0] ins_rd_addr,
	 input  wire       ins_rd_txn_ack,
	 input  wire       ins_rd_txn_cpl,

	// CLK & RST
	 input  wire clk,
	 input  wire rst
);

	// Internal Wiring
	wire [15:0][7:0] reg_line;
	wire [15:0][7:0] data_line;
	wire [7:0] load_addr;
	wire [7:0] insr_o;
	wire [7:0] insr_w;
	wire [3:0] src_a;
	wire [3:0] src_b;
	wire [3:0] dst_f;
	wire [3:0] opcode;
	wire [7:0] flags;

	// Internal Registers
	reg [1:0] stat_reg;
	reg       load_en;

	load_register#(
	    .WORD_LENGTH(8)
	) insr (
		.q(insr_o),
		.data(insr_w),
		.load(insr_le),
		.clk(clk),
		.rst(rst)
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
			stat_reg <= 0;
		end else begin
			case (stat_reg)
				2'b00: begin // FETCH
					if (insr_le) begin
						stat_reg <= 2'b01; // DEX
					end
				end
				2'b01: begin // DEX
					stat_reg <= 2'b00; // FETCH
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
		.load_en  (load_en),
		.alu_ce_n (alu_ce_n),
		.flags    (flags),
		.fetch    (~|stat_reg),
		.insr     (insr_o),
		.ce_n     (alu_ce_n)
	);

	mx11seu inst_mx11seu (
		.reg_line  (reg_line),
		.data_line (data_line),
		.load_addr (load_addr),
		.fetch     (fetch),
		.opcode    (opcode),
		.src_a     (src_a),
		.src_b     (src_b),
		.dst_f     (dst_f),
		.cs_n      (alu_ce_n)
	);

	mxregs #(
		.WORD_LENGTH(8),
		.DEPTH(16)
	) inst_mxregs (
		.reg_line  (reg_line),
		.data_line (data_line),
		.load_addr (load_addr),
		.load_en   (load_en),
		.clk       (clk),
		.rst       (rst)
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
		.fetch            (~|stat_reg),
		.insr             (insr_w),
		.load_en          (insr_le),
		.clk              (clk),
		.rst              (rst)
	);


endmodule