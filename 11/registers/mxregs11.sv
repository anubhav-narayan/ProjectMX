module mxregs11 #(
	parameter bit PIPELINE_INSP_WRITE = 1'b0
) (
	// Main Read Bus
	 input  wire [3:0] m_rd_addr,
	output logic [7:0] m_rd_data,
	// Auxillary Read Bus
	 input  wire [3:0] a_rd_addr,
	output logic [7:0] a_rd_data,
	// Main Write Bus
	 input wire [3:0] m_wr_addr,
	 input wire [7:0] m_wr_data,
	 input wire       m_wr_le,
	// Auxillary Write Bus
	 input wire [3:0] a_wr_addr,
	 input wire [7:0] a_wr_data,
	 input wire       a_wr_le,
	// Peripheral Registers
	output logic [7:0] reg_flags,
	output logic [7:0] reg_insp,
	output logic [7:0] reg_dar,
	// Interrupts
	 input wire nmi,
	 input wire irq,
	// Dedicated INSP update for pipelined fetch
	 input wire       insp_wr_le,
	 input wire [7:0] insp_wr_data,
	// CLK & RST
	 input wire clk,
	 input wire rst
);

	logic [15:0][7:0] regs;
	logic [15:0] write_mask;
	wire ctxs = regs[7][6]; // Context Switch Flag in FLAGS register (0x7)
	logic ctxs_d; // Delayed version of ctxs for edge detection

	always_comb begin
		write_mask = 16'hFFFF; // Default: all registers writable
		if (ctxs) begin
			write_mask[15:8] = 8'h00; // Disable writes to registers 8-15 during CTXS
		end
	end

	assign reg_flags = regs[7]; // FLAGS register is at index 7
	assign reg_insp  = regs[6]; // INSP register is at index 6
	assign reg_dar   = regs[5]; // DAR register is at index 5

    // Write logic
    always_ff @(posedge clk) begin
        if (rst) begin
        	for (int i = 0; i < 16; i++) begin
	            regs[i] <= 8'h0;
        	end
        end else begin
			ctxs_d <= ctxs;
			if (ctxs && !ctxs_d) begin
				for (int i = 0; i < 7; i++) begin
					regs[8+i] <= regs[i]; // Save context: regs[8-16] = regs[0-7]
				end
				if (PIPELINE_INSP_WRITE && insp_wr_le) begin
					regs[14] <= insp_wr_data;
				end
				regs[15][5:0] <= regs[7][5:0]; // Save FLAGS register (0x7) to context
			end
			if (!ctxs && ctxs_d) begin
				for (int i = 0; i < 8; i++) begin
					regs[i] <= regs[8+i]; // Restore context: regs[0-7] = regs[8-16]
				end
			end
			if (nmi) begin
				regs[7][7] <= 1'b1; // Set NMI/IRQ flag in FLAGS register (0x7)
			end
			if (irq & ~regs[7][7]) begin
				regs[7][7] <= 1'b1; // Set IRQ flag in FLAGS register (0x7)
			end
			if (m_wr_le && a_wr_le && (m_wr_addr == a_wr_addr) && write_mask[m_wr_addr]) begin
            	// Conflict: main write wins
            	regs[m_wr_addr] <= m_wr_data;
			end else begin
				if (m_wr_le && write_mask[m_wr_addr]) begin
            		regs[m_wr_addr] <= m_wr_data;
            	end
            	if (a_wr_le && write_mask[a_wr_addr]) begin
            		regs[a_wr_addr] <= a_wr_data;
            	end
			end
			if (PIPELINE_INSP_WRITE && insp_wr_le && write_mask[4'h6]) begin
				regs[4'h6] <= insp_wr_data;
			end
        end
    end

    // Read logic
    assign m_rd_data = regs[m_rd_addr];
    assign a_rd_data = regs[a_rd_addr];

endmodule : mxregs11