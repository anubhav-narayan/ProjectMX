module mxbus_rom#(
	parameter integer ADDR_WIDTH = 8,
	parameter integer DATA_WIDTH = 8
)(  
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

    reg [ADDR_WIDTH-1:0][DATA_WIDTH-1:0] mem;
    // integer x;

    always @(posedge clk) begin
        if(rst) begin
            s0_rd_ready <= 1'b0;
            for (int x=0; x < 2**ADDR_WIDTH; x++) begin
                mem[x] <= 'h0;
            end
        end else begin
            s0_rd_ready <= 1'b1;
            if (s0_rd_txn_start) begin
                s0_rd_txn_ack <= 1'b1;
                s0_rd_data <= mem[s0_rd_addr];
                s0_rd_txn_cpl <= 1'b1;
            end else begin
                s0_rd_txn_ack <= 1'b0;
                s0_rd_data <= 'h00;
                s0_rd_txn_cpl <= 1'b0;
            end
        end
    end

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

    reg [ADDR_WIDTH-1:0][DATA_WIDTH-1:0] mem;
    // integer x;

    always @(posedge clk) begin
        if(rst) begin
            s0_rd_ready <= 1'b0;
            s0_wr_ready <= 1'b0;
            for (int x=0; x < 2**ADDR_WIDTH; x++) begin
                mem[x] <= 'h0;
            end
        end else begin
            s0_rd_ready <= 1'b1;
            s0_wr_ready <= 1'b1;
            if (s0_rd_txn_start) begin
                s0_rd_txn_ack <= 1'b1;
                s0_rd_data <= mem[s0_rd_addr];
                s0_rd_txn_cpl <= 1'b1;
            end else begin
                s0_rd_txn_ack <= 1'b0;
                s0_rd_data <= 'h00;
                s0_rd_txn_cpl <= 1'b0;
            end
            if (s0_wr_txn_start) begin
                s0_wr_txn_ack <= 1'b1;
                mem[s0_wr_addr] <= s0_wr_data;
                s0_wr_txn_cpl <= 1'b1;
            end else begin
                s0_wr_txn_ack <= 1'b0;
                s0_wr_txn_cpl <= 1'b0;
            end
        end
    end

endmodule