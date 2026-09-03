/*****************************************************************************
 * MX Avalon Bridge
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
 * Date : 2024 - 11 - 11
 ****************************************************************************/

module mx_avmm_bridge#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8,
	parameter bit READ_FIRST = 1
)(
	 input  wire clk,
	 input  wire rst,
	// Avalon MM
	output logic [ADDR_WIDTH-1:0] m0_address, // Address bus
	 input  wire                  m0_waitrequest, // Wait request
	output logic [DATA_WIDTH-1:0] m0_writedata, // Write data bus
	 input  wire [DATA_WIDTH-1:0] m0_readdata, // Read data bus
	output logic                  m0_write, // Write enable signal
	output logic                  m0_read // Read enable signal
	// MX Read Bus
	 input  wire                  s0_rd_txn_start,
	output  wire [DATA_WIDTH-1:0] s0_rd_data,
	 input  wire                  s0_rd_ready,
	 input  wire [ADDR_WIDTH-1:0] s0_rd_addr,
	 input  wire                  s0_rd_txn_ack,
	 input  wire                  s0_rd_txn_cpl,
	// MX Write Bus
	 input  wire                  s0_wr_txn_start,
	 input  wire [DATA_WIDTH-1:0] s0_wr_data,
	output  wire                  s0_wr_ready,
	 input  wire [ADDR_WIDTH-1:0] s0_wr_addr,
	output  wire                  s0_wr_txn_ack,
	output  wire                  s0_wr_txn_cpl
);

	enum bit[2:0] {
		IDLE,
		READ_ACK,
		READ,
		READ_CPL,
		WRITE_ACK,
		WRITE,
		WRITE_CPL
	} state;

	reg pending_write, pending_read;

	always_ff @(posedge clk) begin
		if(rst) begin
			state <= IDLE;
			pending_read <= 1'b0;
			pending_write <= 1'b0;
		end else begin
			case (state)
				IDLE: begin
					if (s0_rd_txn_start & s0_wr_txn_start) begin
						state <= READ_FIRST ? READ_ACK : WRITE_ACK;
						{pending_read, pending_write} <= READ_FIRST ? 2'b01 : 2'b10;
					end
					if (s0_rd_txn_start & ~s0_wr_txn_start) begin
						state <= READ_ACK;
					end
					if (~s0_rd_txn_start & s0_wr_txn_start) begin
						state <= WRITE_ACK;
					end
				end
				READ_ACK: begin
					m0_address = s0_rd_addr;
					m0_read = 1'b1;
					state <= READ;
				end
				READ: begin
					if (~m0_waitrequest) begin
						state <= READ_CPL;
						read <= 1'b0;
					end
				end
				READ_CPL: begin
					s0_rd_data <= m0_readdata;
					s0_rd_txn_cpl <= 1'b1;
					if (pending_write) begin
						state <= WRITE_ACK;
					end else begin
						state <= IDLE;
					end
				end
				WRITE_ACK: begin
					m0_address = s0_wr_addr;
					m0_writedata = s0_wr_data;
					m0_write = 1'b1;
					state <= WRITE;
				end
				WRITE: begin
					if (~m0_waitrequest) begin
						state <= WRITE_CPL;
						write <= 1'b0;
					end
				end
				WRITE_CPL: begin
					s0_wr_txn_cpl <= 1'b1;
					if (pending_read) begin
						state <= READ_ACK;
					end else begin
						state <= IDLE;
					end
				end
			endcase
		end
	end


endmodule
