/*****************************************************************************
 * MX Bus Interface Unit
 * Copyright 2023 Anubhav Mattoo
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 * 
 * Author : Anubhav Mattoo <anubhavmattoo@outlook.com>
 * Date : 2023 - 03 - 08
 ****************************************************************************/

module mxbiu_ins#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8
)(  
    // MX Bus Read Master
    output  wire                  m0_rd_txn_start,
     input  wire [DATA_WIDTH-1:0] m0_rd_data,
     input  wire                  m0_rd_ready,
    output  wire [ADDR_WIDTH-1:0] m0_rd_addr,
     input  wire                  m0_rd_txn_ack,
     input  wire                  m0_rd_txn_cpl,

    // Internal Signal
     input wire [ADDR_WIDTH-1:0] insp,
     input wire                  ce_n,
    output wire [DATA_WIDTH-1:0] insr,
    output wire                  valid,

    // CLK & RST
     input  wire clk,
     input  wire rst
);
	
	// Internal Registers
	reg rd_txn_start_r;
	reg [DATA_WIDTH-1:0] rd_data_r;
	reg [1:0] rd_state;

	// Internal Wiring
	assign m0_rd_addr = insp;
	assign m0_rd_txn_start = rd_txn_start_r;
	assign insr = rd_data_r;
	assign valid = m0_rd_txn_cpl;


	always @(posedge clk) begin
		if(rst) begin
			rd_txn_start_r <= 1'b0;
			rd_state <= 2'h0;
			rd_data_r <= 'h0;
		end else begin
			case (rd_state)
				2'h0: begin // IDLE
					if (m0_rd_ready & ~ce_n) begin
						rd_txn_start_r <= 1'b1;
						rd_state <= 2'h1; // TXN_START
					end
				end
				2'h1: begin // TXN_START
					if (m0_rd_txn_ack & ~m0_rd_txn_cpl) begin
						rd_txn_start_r <= 1'b0;
						rd_state <= 2'h2; // TXN_ACK
					end else if (m0_rd_txn_ack & m0_rd_txn_cpl) begin
						rd_txn_start_r <= 1'b0;
						rd_data_r <= m0_rd_data;
						rd_state <= 2'h0; // TXN_IDLE
					end
				end
				2'h2: begin // TXN_ACK
					if (m0_rd_txn_cpl) begin
						rd_data_r <= m0_rd_data;
						rd_state <= 2'h0; // TXN_IDLE
					end
				end
				default: ;
			endcase
		end
	end

endmodule


module mxbiu_data#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8
)(
	// MX Bus Write Master
    output  wire                  m0_wr_txn_start,
    output  wire [DATA_WIDTH-1:0] m0_wr_data,
     input  wire                  m0_wr_ready,
    output  wire [ADDR_WIDTH-1:0] m0_wr_addr,
     input  wire                  m0_wr_txn_ack,
     input  wire                  m0_wr_txn_cpl,
    
    // MX Bus Read Master
    output  wire                  m0_rd_txn_start,
     input  wire [DATA_WIDTH-1:0] m0_rd_data,
     input  wire                  m0_rd_ready,
    output  wire [ADDR_WIDTH-1:0] m0_rd_addr,
     input  wire                  m0_rd_txn_ack,
     input  wire                  m0_rd_txn_cpl,

    // Internal Signal
     input logic [ADDR_WIDTH-1:0] rd_addr,
	output logic [DATA_WIDTH-1:0] rdata,
	output logic                  load_ready,
	 input logic                  load,
	output logic                  load_valid,
     input logic [ADDR_WIDTH-1:0] wr_addr,
	 input logic [DATA_WIDTH-1:0] wdata,
	output logic                  store_ready,
	 input logic                  store,
	output logic                  store_valid,

    // CLK & RST
     input  wire clk,
     input  wire rst
);
	
	// Internal Registers
	reg rd_txn_start_r;
	reg [ADDR_WIDTH-1:0] rd_addr_r;
	reg [1:0] rd_state;

	reg wr_txn_start_r;
	reg [ADDR_WIDTH-1:0] wr_addr_r;
	reg [DATA_WIDTH-1:0] wr_data_r;
	reg [1:0] wr_state;

	// Internal Wiring
	assign m0_rd_txn_start = rd_txn_start_r;
	assign m0_wr_txn_start = wr_txn_start_r;
	assign m0_rd_addr = rd_addr_r;
	assign m0_wr_addr = wr_addr_r;
	assign rdata = m0_rd_data;
	assign m0_wr_data = wr_data_r;
	assign load_valid = m0_rd_txn_cpl;
	assign store_valid = m0_wr_txn_cpl;
	assign load_ready = m0_rd_ready;
	assign store_ready = m0_wr_ready;

	always @(posedge clk) begin
		if(rst) begin
			rd_txn_start_r <= 1'b0;
			rd_state <= 2'h0;
		end else begin
			case (rd_state)
				2'h0: begin // IDLE
					if (m0_rd_ready & load) begin
						rd_addr_r <= rd_addr;
						rd_txn_start_r <= 1'b1;
						rd_state <= 2'h1; // TXN_START
					end
				end
				2'h1: begin // TXN_START
					if (m0_rd_txn_ack & ~m0_rd_txn_cpl) begin
						rd_txn_start_r <= 1'b0;
						rd_state <= 2'h2; // TXN_ACK
					end else if (m0_rd_txn_ack & m0_rd_txn_cpl) begin
						rd_txn_start_r <= 1'b0;
						rd_state <= 2'h0; // IDLE
					end
				end
				2'h2: begin // TXN_ACK
					if (m0_rd_txn_cpl) begin
						rd_state <= 2'h0; // IDLE
					end
				end
				default: ;
			endcase
		end
	end

	always @(posedge clk) begin
		if(rst) begin
			wr_txn_start_r <= 1'b0;
			wr_data_r <= 'h0;
			wr_state <= 2'h0;
		end else begin
			 case (wr_state)
			 	2'h0: begin // IDLE
			 		if (m0_wr_ready & store) begin
						wr_addr_r <= wr_addr;
						wr_data_r <= wdata;
			 			wr_txn_start_r <= 1'b1;
			 			wr_state <= 2'h1; // TXN_START
			 		end
			 	end
			 	2'h1: begin // TXN_START
			 		if (m0_wr_txn_ack & ~m0_wr_txn_cpl) begin
			 			wr_txn_start_r <= 1'b0;
			 			wr_state <= 2'h2; // TXN_ACK
			 		end else if (m0_wr_txn_ack & m0_wr_txn_cpl) begin
			 			wr_txn_start_r <= 1'b0;
			 			wr_state <= 2'h0; // IDLE
			 		end
			 	end
			 	2'h2: begin // TXN_ACK
			 		if (m0_wr_txn_cpl) begin
			 			wr_state <= 2'h0; // IDLE
			 		end
			 	end
				default: ;
			 endcase
		end
	end

endmodule