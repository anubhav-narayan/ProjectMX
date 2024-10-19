module mx11seu(
	// Register Bus
	 input logic [15:0][7:0] reg_line,
	output logic [15:0][7:0] data_line,
	output logic       [7:0] load_addr,
	// ALU OPS
	 input logic             fetch,
	 input logic             ldi,
	 input logic       [7:0] ldv,
	 input logic       [3:0] opcode,
	 input logic       [3:0] src_a,
	 input logic       [3:0] src_b,
	 input logic       [3:0] dst_f,
	 input logic       cs_n
);
	
	// Internal Wire
	wire [7:0] f;
	wire [4:0] flags;
	wire [7:0] a;
	wire [7:0] b;

	// assign load_addr = |opcode & fetch ? {4'h0, dst_f} : {4'h1, dst_f};
	always_comb begin
		if (fetch) begin
			load_addr = {4'h0, dst_f};
		end
		case (opcode)
			4'h3, 4'h8, 4'h9, 4'hA, 4'hB, 4'hC, 4'hD: begin
				load_addr = {4'h1, dst_f};
			end
			default: begin
				load_addr = {4'h0, dst_f};
			end
		endcase
	end
	
	always_comb begin
		case (dst_f)
			4'h0: data_line = {{8{8'h00}}, {reg_line[7][7:5], flags}, {6{8'h00}}, f};
			4'h1: data_line = {{8{8'h00}}, {reg_line[7][7:5], flags}, {5{8'h00}}, f, 8'h00};
			4'h2: data_line = {{8{8'h00}}, {reg_line[7][7:5], flags}, {4{8'h00}}, f, {2{8'h00}}};
			4'h3: data_line = {{8{8'h00}}, {reg_line[7][7:5], flags}, {3{8'h00}}, f, {3{8'h00}}};
			4'h4: data_line = {{8{8'h00}}, {reg_line[7][7:5], flags}, {2{8'h00}}, f, {4{8'h00}}};
			4'h5: data_line = {{8{8'h00}}, {reg_line[7][7:5], flags}, {1{8'h00}}, f, {5{8'h00}}};
			4'h6: data_line = {{8{8'h00}}, {reg_line[7][7:5], flags}, f, {6{8'h00}}};
			4'h7: data_line = {{8{8'h00}}, f, {7{8'h00}}}; // FLAGS Handling
			4'h8: data_line = {{7{8'h00}}, f, {reg_line[7][7:5], flags}, {7{8'h00}}};
			4'h9: data_line = {{6{8'h00}}, f, 8'h00, {reg_line[7][7:5], flags}, {7{8'h00}}};
			4'hA: data_line = {{5{8'h00}}, f, {2{8'h00}}, {reg_line[7][7:5], flags}, {7{8'h00}}};
			4'hB: data_line = {{4{8'h00}}, f, {3{8'h00}}, {reg_line[7][7:5], flags}, {7{8'h00}}};
			4'hC: data_line = {{3{8'h00}}, f, {4{8'h00}}, {reg_line[7][7:5], flags}, {7{8'h00}}};
			4'hD: data_line = {{2{8'h00}}, f, {5{8'h00}}, {reg_line[7][7:5], flags}, {7{8'h00}}};
			4'hE: data_line = {8'h00, f, {6{8'h00}}, {reg_line[7][7:5], flags}, {7{8'h00}}};
			4'hF: data_line = {f, {7{8'h00}}, {reg_line[7][7:5], flags}, {7{8'h00}}};
		endcase
	end

	reg_tap #(
		.DATA_WIDTH(8),
		.DEPTH(16)
	) reg_tap_a (
		.data     (a),
		.reg_line (reg_line),
		.reg_addr (src_a)
	);

	reg_tap #(
		.DATA_WIDTH(8),
		.DEPTH(16)
	) reg_tap_b (
		.data     (b),
		.reg_line (reg_line),
		.reg_addr (src_b)
	);

	mxalu11u inst_mxalu11u (
		.f(f),
		.x(),
		.y(),
		.flags(flags),
		.opcode(opcode),
		.a(ldi ? ldv : a),
		.b(b),
		.cs_n(cs_n)
	);


endmodule