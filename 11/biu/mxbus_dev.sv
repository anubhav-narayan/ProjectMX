module mxbus_rom#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8,
    parameter string ROM_FILE = ""
)(  
    // MX Bus Read Slave
     input wire                  s0_rd_txn_start,
    output wire [DATA_WIDTH-1:0] s0_rd_data,
    output  reg                  s0_rd_ready,
     input wire [ADDR_WIDTH-1:0] s0_rd_addr,
    output  reg                  s0_rd_txn_ack,
    output  reg                  s0_rd_txn_cpl,

    // CLK & RST
     input  wire clk,
     input  wire rst
);

    bit [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];
    integer fid, rb;

    initial begin
        if (ROM_FILE == "") begin
            for (int i = 0; i < 2**ADDR_WIDTH; i++) begin
                mem[i] = 'h0;
            end
        end else begin
            fid = $fopen(ROM_FILE,"rb");
            if (fid == 0) begin
                $display("File Error!");
            end
            rb = $fread(mem, fid);
            $display("Read %d bytes", rb);
        end
    end

    assign s0_rd_data = mem[s0_rd_addr];
    assign s0_rd_ready = 1'b1;
    assign s0_rd_txn_ack = s0_rd_txn_start;
    assign s0_rd_txn_cpl = s0_rd_txn_start;

endmodule


module mxbus_ram#(
    parameter integer ADDR_WIDTH = 8,
    parameter integer DATA_WIDTH = 8
)(  
    // MX Bus Write Slave
     input wire                  s0_wr_txn_start,
     input wire [DATA_WIDTH-1:0] s0_wr_data,
    output  reg                  s0_wr_ready,
     input wire [ADDR_WIDTH-1:0] s0_wr_addr,
    output  reg                  s0_wr_txn_ack,
    output  reg                  s0_wr_txn_cpl,

    // MX Bus Read Slave
     input wire                  s0_rd_txn_start,
    output  reg [DATA_WIDTH-1:0] s0_rd_data,
    output  reg                  s0_rd_ready,
     input wire [ADDR_WIDTH-1:0] s0_rd_addr,
    output  reg                  s0_rd_txn_ack,
    output  reg                  s0_rd_txn_cpl,

    // CLK & RST
     input  wire clk,
     input  wire rst
);

    reg [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];
    bit [1:0] rd_state, wr_state;
    // integer x;

    always @(posedge clk) begin
        if(rst) begin
            rd_state <= 1'b0;
            s0_rd_ready <= 1'b0;
            s0_rd_txn_ack <= 1'b0;
            s0_rd_txn_cpl <= 1'b0;
            wr_state <= 1'b0;
            s0_wr_ready <= 1'b0;
            s0_wr_txn_ack <= 1'b0;
            s0_wr_txn_cpl <= 1'b0;
        end else begin
            case (rd_state)
                1'b0: begin
                    s0_rd_ready <= 1'b1;
                    if (s0_rd_txn_start) begin
                        s0_rd_data = mem[s0_rd_addr];
                        s0_rd_txn_ack <= 1'b1;
                        s0_rd_txn_cpl <= 1'b1;
                        rd_state <= 1'b1;
                    end
                end
                1'b1: begin
                    rd_state <= 1'b0;
                    s0_rd_ready <= 1'b0;
                    s0_rd_txn_ack <= 1'b0;
                    s0_rd_txn_cpl <= 1'b0;
                end
            endcase
            case (wr_state)
                1'b0: begin
                    s0_wr_ready <= 1'b1;
                    if (s0_wr_txn_start) begin
                        mem[s0_wr_addr] = s0_wr_data;
                        s0_wr_txn_ack <= 1'b1;
                        s0_wr_txn_cpl <= 1'b1;
                        wr_state <= 1'b1;
                    end
                end
                1'b1: begin
                    wr_state <= 1'b0;
                    s0_wr_ready <= 1'b0;
                    s0_wr_txn_ack <= 1'b0;
                    s0_wr_txn_cpl <= 1'b0;
                end
            endcase
        end
    end

endmodule