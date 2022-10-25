module alu_flags (
	output [7:0] flags,
	 input [7:0] f,
	 input       a_b,
	 input       cn_n,
	 input       cn8_n
);
	
	assign flags[0] = ~|f; // Zero
	assign flags[1] = ~cn8_n; // Carry
	assign flags[2] = a_b; // Equal
	assign flags[3] = ~cn_n & cn8_n; // Lesser Than
	assign flags[4] = cn_n & ~cn8_n; // Greater Than

endmodule