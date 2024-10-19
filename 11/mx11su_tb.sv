`timescale 1ps/1fs

module mx11su_tb;
	bit clk;
	bit [1:0] rst;
	// Interrupts
	bit nmi;
	bit irq;


	typedef enum logic [7:0] {
	    NOP       = 8'h00,
	    NOT       = 8'h01,
	    NAND      = 8'h02,
	    XOR       = 8'h03,
	    XNOR      = 8'h04,
	    AND       = 8'h05,
	    OR        = 8'h06,
	    NOR       = 8'h07,
	    ADD       = 8'h08,
	    ADC       = 8'h09,
	    SUB       = 8'h0a,
	    SBB       = 8'h0b,
	    INCR      = 8'h0c,
	    DECR      = 8'h0d,
	    X2        = 8'h0e,
	    CLR       = 8'h0f,
	    RST       = 8'h6f,
	    SHM       = 8'h94,
	    JNZ       = 8'ha0,
	    JZ        = 8'ha1,
	    JNC       = 8'ha2,
	    JC        = 8'ha3,
	    JNE       = 8'ha4,
	    JE        = 8'ha5,
	    JLT       = 8'ha6,
	    JGT       = 8'ha7,
	    RJNZ      = 8'ha8,
	    RJZ       = 8'ha9,
	    RJNC      = 8'haa,
	    RJC       = 8'hab,
	    RJNE      = 8'hac,
	    RJE       = 8'had,
	    RJLT      = 8'hae,
	    RJGT      = 8'haf,
	    INTR      = 8'hf2,
	    HALT      = 8'hff,
	    INCR_X    = 8'h1c,
	    INCR_Y    = 8'h2c,
	    INCR_D    = 8'h3c,
	    INCR_DAR  = 8'h4c,
	    INCR_MBR  = 8'h5c,
	    INCR_INSP = 8'h6c,
	    INCR_FLAGS= 8'h7c,
	    DECR_X    = 8'h1d,
	    DECR_Y    = 8'h2d,
	    DECR_D    = 8'h3d,
	    DECR_DAR  = 8'h4d,
	    DECR_MBR  = 8'h5d,
	    DECR_INSP = 8'h6d,
	    DECR_FLAGS= 8'h7d,
	    MOV_A_X   = 8'h10,
	    MOV_A_Y   = 8'h20,
	    MOV_A_D   = 8'h30,
	    MOV_D_A   = 8'h40,
	    MOV_D_X   = 8'h50,
	    MOV_D_Y   = 8'h60,
	    MOV_D_MBR = 8'h70,
	    MOV_X_A   = 8'h80,
	    MOV_X_Y   = 8'h84,
	    MOV_X_D   = 8'h86,
	    MOV_Y_A   = 8'h81,
	    MOV_Y_D   = 8'h87,
	    NOT_X     = 8'h11,
	    NOT_Y     = 8'h21,
	    NOT_D     = 8'h31,
	    NAND_D_A  = 8'h42,
	    NAND_D_X  = 8'h52,
	    NAND_D_Y  = 8'h62,
	    NAND_D_D  = 8'h72,
	    XOR_D_A   = 8'h43,
	    XOR_D_X   = 8'h53,
	    XOR_D_Y   = 8'h63,
	    XOR_D_D   = 8'h73,
	    XNOR_D_A  = 8'h44,
	    XNOR_D_X  = 8'h54,
	    XNOR_D_Y  = 8'h64,
	    XNOR_D_D  = 8'h74,
	    AND_D_A   = 8'h45,
	    AND_D_X   = 8'h55,
	    AND_D_Y   = 8'h65,
	    AND_D_D   = 8'h75,
	    OR_D_A    = 8'h46,
	    OR_D_X    = 8'h56,
	    OR_D_Y    = 8'h66,
	    OR_D_D    = 8'h76,
	    NOR_D_A   = 8'h47,
	    NOR_D_X   = 8'h57,
	    NOR_D_Y   = 8'h67,
	    NOR_D_D   = 8'h77,
	    ADD_D_A   = 8'h48,
	    ADD_D_X   = 8'h58,
	    ADD_D_Y   = 8'h68,
	    ADD_D_D   = 8'h78,
	    SHM_SA    = 8'h90,
	    SHM_SX    = 8'h91,
	    SHM_SY    = 8'h92,
	    SHM_SD    = 8'h93,
	    SHM_X     = 8'h95,
	    SHM_Y     = 8'h96,
	    SHM_D     = 8'h97,
	    CLR_X     = 8'h1f,
	    CLR_Y     = 8'h2f,
	    CLR_D     = 8'h3f,
	    CLR_DAR   = 8'h4f,
	    CLR_MBR   = 8'h5f,
	    CLR_FALGS = 8'h7f,
	    LD_A      = 8'hb0,
	    LD_X      = 8'hb1,
	    LD_Y      = 8'hb2,
	    LD_FALGS  = 8'hb3,
	    LD_R0     = 8'hb4,
	    LD_R1     = 8'hb5,
	    LD_R2     = 8'hb6,
	    LD_R3     = 8'hb7,
	    ST_A      = 8'hb8,
	    ST_X      = 8'hb9,
	    ST_Y      = 8'hba,
	    ST_FALGS  = 8'hbb,
	    ST_R0     = 8'hbc,
	    ST_R1     = 8'hbd,
	    ST_R2     = 8'hbe,
	    ST_R3     = 8'hbf,
	    LDI_0     = 8'he0,
	    LDI_1     = 8'he1,
	    LDI_2     = 8'he2,
	    LDI_3     = 8'he3,
	    LDI_4     = 8'he4,
	    LDI_5     = 8'he5,
	    LDI_6     = 8'he6,
	    LDI_7     = 8'he7,
	    LDI_8     = 8'he8,
	    LDI_9     = 8'he9,
	    LDI_10    = 8'hea,
	    LDI_11    = 8'heb,
	    LDI_12    = 8'hec,
	    LDI_13    = 8'hed,
	    LDI_14    = 8'hee,
	    LDI_15    = 8'hef,
	    SHL_0     = 8'hc0,
	    SHL_1     = 8'hc1,
	    SHL_2     = 8'hc2,
	    SHL_3     = 8'hc3,
	    SHL_4     = 8'hc4,
	    SHL_5     = 8'hc5,
	    SHL_6     = 8'hc6,
	    SHL_7     = 8'hc7,
	    SHR_0     = 8'hd0,
	    SHR_1     = 8'hd1,
	    SHR_2     = 8'hd2,
	    SHR_3     = 8'hd3,
	    SHR_4     = 8'hd4,
	    SHR_5     = 8'hd5,
	    SHR_6     = 8'hd6,
	    SHR_7     = 8'hd7,
	    ROL_0     = 8'hc8,
	    ROL_1     = 8'hc9,
	    ROL_2     = 8'hca,
	    ROL_3     = 8'hcb,
	    ROL_4     = 8'hcc,
	    ROL_5     = 8'hcd,
	    ROL_6     = 8'hce,
	    ROL_7     = 8'hcf,
	    ROR_0     = 8'hd8,
	    ROR_1     = 8'hd9,
	    ROR_2     = 8'hda,
	    ROR_3     = 8'hdb,
	    ROR_4     = 8'hdc,
	    ROR_5     = 8'hdd,
	    ROR_6     = 8'hde,
	    ROR_7     = 8'hdf
	} instruction_t;

	always begin
		#12.5ns clk = ~clk;
	end

	always @(posedge clk) begin
		rst[1] <= rst[0];
	end

	always @* begin
		$display("INSTRUCTION: %s   VALUE: 0x%02x", instruction_t'(inst_mx11su.insr), inst_mx11su.insr);
	end

	initial begin
		rst = 2'b11;
		#25ns rst[0] = 1'b0;
	end

	// MX Bus Write Master
	wire                  data_wr_txn_start;
	wire [           7:0] data_wr_data;
	wire                  data_wr_ready;
	wire [           7:0] data_wr_addr;
	wire                  data_wr_txn_ack;
	wire                  data_wr_txn_cpl;
	
	// MX Bus Read Master
	wire                  data_rd_txn_start;
	wire [           7:0] data_rd_data;
	wire                  data_rd_ready;
	wire [           7:0] data_rd_addr;
	wire                  data_rd_txn_ack;
	wire                  data_rd_txn_cpl;

	// MX Instruction
	wire                  ins_rd_txn_start;
	wire [           7:0] ins_rd_data;
	wire                  ins_rd_ready;
	wire [           7:0] ins_rd_addr;
	wire                  ins_rd_txn_ack;
	wire                  ins_rd_txn_cpl;


	mx11su inst_mx11su(
		.ins_rd_txn_start  (ins_rd_txn_start),
		.ins_rd_data       (ins_rd_data),
		.ins_rd_ready      (ins_rd_ready),
		.ins_rd_addr       (ins_rd_addr),
		.ins_rd_txn_ack    (ins_rd_txn_ack),
		.ins_rd_txn_cpl    (ins_rd_txn_cpl),
		.data_wr_txn_start (data_wr_txn_start),
		.data_wr_data      (data_wr_data),
		.data_wr_ready     (data_wr_ready),
		.data_wr_addr      (data_wr_addr),
		.data_wr_txn_ack   (data_wr_txn_ack),
		.data_wr_txn_cpl   (data_wr_txn_cpl),
		.data_rd_txn_start (data_rd_txn_start),
		.data_rd_data      (data_rd_data),
		.data_rd_ready     (data_rd_ready),
		.data_rd_addr      (data_rd_addr),
		.data_rd_txn_ack   (data_rd_txn_ack),
		.data_rd_txn_cpl   (data_rd_txn_cpl),
		.irq               (irq),
		.nmi               (nmi),
		.clk               (clk),
		.rst               (rst[1])
	);

	// Instruction Memory
	mxbus_rom #(
		.ADDR_WIDTH(8),
		.DATA_WIDTH(8),
		.ROM_FILE("/home/sakae/anubhav/ProjectMX/11/ins.bin")
	) inst_mxbus_rom (
		.s0_rd_txn_start (ins_rd_txn_start),
		.s0_rd_data      (ins_rd_data),
		.s0_rd_ready     (ins_rd_ready),
		.s0_rd_addr      (ins_rd_addr),
		.s0_rd_txn_ack   (ins_rd_txn_ack),
		.s0_rd_txn_cpl   (ins_rd_txn_cpl),
		.clk             (clk),
		.rst             (rst[0])
	);
	// Data Memory
	mxbus_ram #(
		.ADDR_WIDTH(8),
		.DATA_WIDTH(8),
		.RAM_INIT_FILE("/home/sakae/anubhav/ProjectMX/11/data.bin")
	) inst_mxbus_ram (
		.s0_wr_txn_start (data_wr_txn_start),
		.s0_wr_data      (data_wr_data),
		.s0_wr_ready     (data_wr_ready),
		.s0_wr_addr      (data_wr_addr),
		.s0_wr_txn_ack   (data_wr_txn_ack),
		.s0_wr_txn_cpl   (data_wr_txn_cpl),
		.s0_rd_txn_start (data_rd_txn_start),
		.s0_rd_data      (data_rd_data),
		.s0_rd_ready     (data_rd_ready),
		.s0_rd_addr      (data_rd_addr),
		.s0_rd_txn_ack   (data_rd_txn_ack),
		.s0_rd_txn_cpl   (data_rd_txn_cpl),
		.clk             (clk),
		.rst             (rst[0])
	);
endmodule
