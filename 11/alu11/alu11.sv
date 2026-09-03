module alu11 (
     input  wire [7:0] a,
     input  wire [7:0] b,
     input  wire       carry_in,
     input  wire [3:0] opcode,
    output logic [7:0] f,
    output logic       g,
    output logic       p,
    output logic       carry_out,
    output logic [5:0] flags
);

    /*
    +--------+----------+-------------------------+--------------------------------+
    | Opcode | Mnemonic | Operation               | Flag Behavior (summary)        |
    +--------+----------+-------------------------+--------------------------------+
    |   0    | BUF      | f = a                   | Flags from result              |
    |   1    | CLR      | f = 0                   | Z=1, others cleared            |
    |   2    | NOT      | f = ~a                  | Flags from result              |
    |   3    | XOR      | f = a ^ b               | Flags from result              |
    |   4    | AND      | f = a & b               | Flags from result              |
    |   5    | OR       | f = a | b               | Flags from result              |
    |   6    | —        | (unused)                | —                              |
    |   7    | —        | (unused)                | —                              |
    |   8    | INCR     | f = a + 1               | Carry/Overflow from addition   |
    |   9    | DECR     | f = a - 1               | Carry/Overflow from subtraction|
    |   A    | ADD      | f = a + b               | Carry, Overflow set            |
    |   B    | ADC      | f = a + b + carry_in    | Carry, Overflow set            |
    |   C    | SUB      | f = a - b               | Carry=borrow, Overflow set     |
    |   D    | SBB      | f = a - b - carry_in    | Carry=borrow, Overflow set     |
    |   E    | CMP      | f = a - b (discarded)   | Flags only: Z/E/L/G updated    |
    |   F    | —        | (unused)                | —                              |
    +--------+----------+-------------------------+--------------------------------+
    */

    wire [6:0] int_carry;
	logic carry_in_int;
	logic [1:0] cin_sel;

    always_comb begin
		case (cin_sel)
			2'h0: begin
				carry_in_int = carry_in;
			end
            2'h1: begin
                carry_in_int = ~carry_in;
            end
			2'h2: begin
				carry_in_int = 0;
			end
			2'h3: begin
				carry_in_int = 1;
			end
            default: begin
                carry_in_int = carry_in;
            end
		endcase
	end

    always_comb begin
		case (opcode)
			4'h8, 4'hC, 4'hE: begin
				cin_sel = 2'h3;
			end
			4'h9, 4'hA: begin
				cin_sel = 2'h2;
			end
			4'hD: begin
				cin_sel = 2'h1;
			end
			default: begin
				cin_sel = 2'h0;
			end
		endcase
	end

    assign {g, p} = {carry_out, int_carry[6]};

    generate
        genvar x;
        alu11_cell alu11_cell0(
            .a         (a[0]),
            .b         (b[0]),
            .carry_in  (carry_in_int),
            .opcode    (opcode),
            .f         (f[0]),
            .g         (),
            .p         (),
            .carry_out (int_carry[0])
        );
        for (x = 1; x < 7; x++) begin: alu_cellN
            alu11_cell alu11_cellN(
                .a         (a[x]),
                .b         (b[x]),
                .carry_in  (int_carry[x-1]),
                .opcode    (opcode),
                .f         (f[x]),
                .g         (),
                .p         (),
                .carry_out (int_carry[x])
            );
        end
        alu11_cell alu11_cell7(
            .a         (a[7]),
            .b         (b[7]),
            .carry_in  (int_carry[6]),
            .opcode    (opcode),
            .f         (f[7]),
            .g         (),
            .p         (),
            .carry_out (carry_out)
        );
    endgenerate

    assign flags[0] = ~|f;                       // Z
    assign flags[1] = carry_out;                 // C
    assign flags[2] = g ^ p;                     // O
    assign flags[3] = ~|f;                       // E
    assign flags[4] = f[7] ^ g ^ p;              // L
    assign flags[5] = ~((f[7] ^ g ^ p) | (~|f)); // G

endmodule
