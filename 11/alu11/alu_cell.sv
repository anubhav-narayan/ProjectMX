module alu_cell (
	 input  wire a,
	 input  wire b,
	 input  wire carry_in,
	 input  wire [2:0] opcode,
	output logic f,
	output logic g,
	output logic p,
	output logic carry_out
);
	
	wire p_xor;
	wire p_and;
	wire p_or;
	wire p_sum;

	assign p_xor = a ^ b;
	assign p_and = a & b;
	assign p_sum = p_xor ^ carry_in;
	assign p_or = a | b;
	assign carry_out = (carry_in & p_xor) | p_and;
	assign g = p_xor;
	assign p = p_and;

	always_comb begin
		case (opcode)
			'h0: begin
				f = a; // BUF
			end
			'h1: begin
				f = 0; // CLR
			end
			'h2: begin
				f = ~a; // NOT
			end
			'h3: begin
				f = p_xor; // XOR
			end
			'h4: begin
				f = p_and; // AND
			end
			'h5: begin
				f = p_or; // OR
			end
			'h6: begin
				f = p_sum; // ADDER
			end
			'h7: begin
				f = 1; // SET
			end
			default: begin
				f = 0;
			end
		endcase
	end

endmodule : alu_cell