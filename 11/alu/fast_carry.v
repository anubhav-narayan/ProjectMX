/*************************************
 * Fast Carry
 *************************************/

module fast_carry (
	output cnx, go_n, po_n,
	 input [1:0] g_n, p_n,
	 input cn
);
	
	assign cnx = ~((g_n[0] & ~cn) | (g_n[0] & p_n[0]));
	assign go_n = g_n[1] & (p_n[1] | g_n[0]);
	assign po_n = |p_n;

endmodule
