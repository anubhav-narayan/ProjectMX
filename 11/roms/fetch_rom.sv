module fetch_rom (
	output logic [3:0] m_rd_addr,
	output logic [3:0] m_wr_addr,
	output logic [3:0] alu_ins
);

	assign m_rd_addr = 4'h6;
	assign m_wr_addr = 4'h6;
	assign alu_ins = 4'h8;

endmodule : fetch_rom