module cache_ctrl#(
	parameter integer PS_ADDR_WIDTH = 8,
	parameter integer PS_DATA_WIDTH = 8,
	parameter integer MM_DATA_WIDTH = 32,
	parameter integer MM_ADDR_WIDTH = PS_ADDR_WIDTH - ,
	parameter integer WORD_LENGTH = 16
)(
	// MX Bus Write Host Data
	output  wire                     main_wr_txn_start,
	output  wire [MM_DATA_WIDTH-1:0] main_wr_data,
	 input  wire                     main_wr_ready,
	output  wire [MM_ADDR_WIDTH-1:0] main_wr_addr,
	 input  wire                     main_wr_txn_ack,
	 input  wire                     main_wr_txn_cpl,
	
	// MX Bus Read Host Data
	output  wire                     main_rd_txn_start,
	 input  wire [MM_DATA_WIDTH-1:0] main_rd_data,
	 input  wire                     main_rd_ready,
	output  wire [MM_ADDR_WIDTH-1:0] main_rd_addr,
	 input  wire                     main_rd_txn_ack,
	 input  wire                     main_rd_txn_cpl,

	// MX Bus Write Endpoint Data
     input wire                     mem_wr_txn_start,
     input wire [PS_DATA_WIDTH-1:0] mem_wr_data,
    output  reg                     mem_wr_ready,
     input wire [PS_ADDR_WIDTH-1:0] mem_wr_addr,
    output  reg                     mem_wr_txn_ack,
    output  reg                     mem_wr_txn_cpl,

    // MX Bus Read Endpoint Data
     input wire                     mem_rd_txn_start,
    output  reg [PS_DATA_WIDTH-1:0] mem_rd_data,
    output  reg                     mem_rd_ready,
     input wire [PS_ADDR_WIDTH-1:0] mem_rd_addr,
    output  reg                     mem_rd_txn_ack,
    output  reg                     mem_rd_txn_cpl,

    // MX Bus Read Endpoint Instruction
     input wire                     ins_rd_txn_start,
    output wire [PS_DATA_WIDTH-1:0] ins_rd_data,
    output  reg                     ins_rd_ready,
     input wire [PS_ADDR_WIDTH-1:0] ins_rd_addr,
    output  reg                     ins_rd_txn_ack,
    output  reg                     ins_rd_txn_cpl,
);
	typedef struct cache{
		bit [:0]
	}

endmodule