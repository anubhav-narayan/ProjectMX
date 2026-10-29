module seu11_config_mem (
    input  logic        clk,

    // 8-bit byte-addressed loader write bus
    input  logic        cfg_wr_txn_start,
    input  logic [7:0]  cfg_wr_data,
    input  logic [11:0] cfg_wr_addr,
    output logic        cfg_wr_ready,
    output logic        cfg_wr_txn_ack,
    output logic        cfg_wr_txn_cpl,

    // 32-bit word-addressed microcode read bus
    input  logic        cfg_rd_txn_start,
    output logic [31:0] cfg_rd_data,
    output logic        cfg_rd_ready,
    input  logic [9:0]  cfg_rd_addr,
    output logic        cfg_rd_txn_ack,
    output logic        cfg_rd_txn_cpl,

    // Prevent updates to a profile while it is being copied into microcode SRAM.
    input  logic        cfg_profile_lock,
    input  logic [1:0]  cfg_locked_profile
);

    logic [31:0] words [0:1023];

    initial begin
        for (int i = 0; i < 1024; i++) begin
            words[i] = 32'b0;
        end
    end

    assign cfg_wr_ready = !(
        cfg_profile_lock &&
        (cfg_wr_addr[11:10] == cfg_locked_profile)
    );
    assign cfg_wr_txn_ack = cfg_wr_txn_start && cfg_wr_ready;
    assign cfg_wr_txn_cpl = cfg_wr_txn_start && cfg_wr_ready;

    assign cfg_rd_data = words[cfg_rd_addr];
    assign cfg_rd_ready = 1'b1;
    assign cfg_rd_txn_ack = cfg_rd_txn_start;
    assign cfg_rd_txn_cpl = cfg_rd_txn_start;

    always_ff @(posedge clk) begin
        if (cfg_wr_txn_start && cfg_wr_ready) begin
            case (cfg_wr_addr[1:0])
                2'd0: words[cfg_wr_addr[11:2]][7:0]   <= cfg_wr_data;
                2'd1: words[cfg_wr_addr[11:2]][15:8]  <= cfg_wr_data;
                2'd2: words[cfg_wr_addr[11:2]][23:16] <= cfg_wr_data;
                2'd3: words[cfg_wr_addr[11:2]][31:24] <= cfg_wr_data;
            endcase
        end
    end

endmodule
