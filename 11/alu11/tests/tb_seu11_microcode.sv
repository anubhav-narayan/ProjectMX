`timescale 1ns/1ps

module tb_seu11_microcode;
    logic clk = 1'b0;
    logic rst;
    logic [7:0] dar;
    logic [7:0] opcode;

    logic cfg_wr_txn_start;
    logic [7:0] cfg_wr_data;
    logic [11:0] cfg_wr_addr;
    logic cfg_wr_ready;
    logic cfg_wr_txn_ack;
    logic cfg_wr_txn_cpl;

    logic cfg_rd_txn_start;
    logic [31:0] cfg_rd_data;
    logic cfg_rd_ready;
    logic [9:0] cfg_rd_addr;
    logic cfg_rd_txn_ack;
    logic cfg_rd_txn_cpl;
    logic read_gate;
    logic store_rd_ready;
    logic store_rd_txn_ack;
    logic store_rd_txn_cpl;
    logic cfg_profile_lock;
    logic [1:0] cfg_locked_profile;

    logic busy;
    logic use_profile;
    logic profile_wr_en;
    logic [7:0] profile_wr_addr;
    logic [30:0] profile_wr_data;

    logic ldi;
    logic [7:0] imm8;
    logic [3:0] m_rd_addr;
    logic [3:0] a_rd_addr;
    logic m_wr_le;
    logic [3:0] m_wr_addr;
    logic a_wr_le;
    logic [3:0] a_wr_addr;
    logic [3:0] alu_ins;
    logic [30:0] decoded_word;
    integer read_count;

    always #5 clk = ~clk;

    assign decoded_word = {
        ldi,
        imm8,
        m_rd_addr,
        a_rd_addr,
        m_wr_le,
        m_wr_addr,
        a_wr_le,
        a_wr_addr,
        alu_ins
    };

    always_ff @(posedge clk) begin
        if (rst) begin
            read_count <= 0;
        end else if (
            cfg_rd_txn_start &&
            cfg_rd_ready &&
            cfg_rd_txn_ack &&
            cfg_rd_txn_cpl
        ) begin
            read_count <= read_count + 1;
        end
    end

    assign cfg_rd_ready = store_rd_ready && read_gate;
    assign cfg_rd_txn_ack = store_rd_txn_ack && read_gate;
    assign cfg_rd_txn_cpl = store_rd_txn_cpl && read_gate;

    seu11_microcode_controller controller (
        .clk(clk),
        .rst(rst),
        .dar(dar),
        .cfg_rd_txn_start(cfg_rd_txn_start),
        .cfg_rd_data(cfg_rd_data),
        .cfg_rd_ready(cfg_rd_ready),
        .cfg_rd_addr(cfg_rd_addr),
        .cfg_rd_txn_ack(cfg_rd_txn_ack),
        .cfg_rd_txn_cpl(cfg_rd_txn_cpl),
        .busy(busy),
        .use_profile(use_profile),
        .cfg_profile_lock(cfg_profile_lock),
        .cfg_locked_profile(cfg_locked_profile),
        .profile_wr_en(profile_wr_en),
        .profile_wr_addr(profile_wr_addr),
        .profile_wr_data(profile_wr_data)
    );

    seu11_config_mem config_mem (
        .clk(clk),
        .cfg_wr_txn_start(cfg_wr_txn_start),
        .cfg_wr_data(cfg_wr_data),
        .cfg_wr_addr(cfg_wr_addr),
        .cfg_wr_ready(cfg_wr_ready),
        .cfg_wr_txn_ack(cfg_wr_txn_ack),
        .cfg_wr_txn_cpl(cfg_wr_txn_cpl),
        .cfg_rd_txn_start(cfg_rd_txn_start),
        .cfg_rd_data(cfg_rd_data),
        .cfg_rd_ready(store_rd_ready),
        .cfg_rd_addr(cfg_rd_addr),
        .cfg_rd_txn_ack(store_rd_txn_ack),
        .cfg_rd_txn_cpl(store_rd_txn_cpl),
        .cfg_profile_lock(cfg_profile_lock),
        .cfg_locked_profile(cfg_locked_profile)
    );

    seu11_profile_rom #(
        .ROM_FILE("11/alu11/seu.hex")
    ) profile_rom (
        .clk(clk),
        .insr(opcode),
        .use_profile(use_profile),
        .profile_wr_en(profile_wr_en),
        .profile_wr_addr(profile_wr_addr),
        .profile_wr_data(profile_wr_data),
        .ldi(ldi),
        .imm8(imm8),
        .m_rd_addr(m_rd_addr),
        .a_rd_addr(a_rd_addr),
        .m_wr_le(m_wr_le),
        .m_wr_addr(m_wr_addr),
        .a_wr_le(a_wr_le),
        .a_wr_addr(a_wr_addr),
        .alu_ins(alu_ins)
    );

    task automatic write_byte(
        input logic [11:0] address,
        input logic [7:0] value
    );
        @(negedge clk);
        cfg_wr_addr = address;
        cfg_wr_data = value;
        cfg_wr_txn_start = 1'b1;
        #1;
        if (!cfg_wr_ready) begin
            $fatal(1, "unexpected loader backpressure at address %h", address);
        end
        if (!cfg_wr_txn_ack || !cfg_wr_txn_cpl) begin
            $fatal(1, "loader transaction was not acknowledged at address %h", address);
        end
        @(posedge clk);
        @(negedge clk);
        cfg_wr_txn_start = 1'b0;
    endtask

    task automatic write_word(
        input logic [1:0] profile,
        input logic [7:0] word_address,
        input logic [31:0] value
    );
        logic [11:0] byte_address;
        for (int byte_index = 0; byte_index < 4; byte_index++) begin
            byte_address = {profile, word_address, byte_index[1:0]};
            write_byte(byte_address, value[byte_index * 8 +: 8]);
        end
    endtask

    task automatic wait_for_load;
        integer cycles;
        #1;
        cycles = 0;
        while (busy) begin
            @(posedge clk);
            cycles++;
            if (cycles > 2000) begin
                $fatal(1, "profile load did not complete");
            end
        end
        #1;
    endtask

    initial begin
        logic [30:0] first_profile_word;
        logic [30:0] second_profile_word;
        integer previous_read_count;

        rst = 1'b1;
        dar = 8'h00;
        opcode = 8'h35;
        cfg_wr_txn_start = 1'b0;
        cfg_wr_data = 8'h00;
        cfg_wr_addr = 12'h000;
        read_gate = 1'b1;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        first_profile_word = {
            1'b1, 8'hA5, 4'h2, 4'h3, 1'b1, 4'h4, 1'b0, 4'h5, 4'hA
        };
        second_profile_word = {
            1'b0, 8'h3C, 4'h7, 4'h1, 1'b0, 4'h8, 1'b1, 4'h9, 4'h3
        };
        write_word(2'd0, 8'h35, {1'b0, first_profile_word});
        write_word(2'd1, 8'h35, {1'b0, second_profile_word});

        @(negedge clk);
        read_gate = 1'b0;
        dar = 8'h04;
        #1;
        if (!busy || !cfg_profile_lock || cfg_locked_profile != 2'd0) begin
            $fatal(1, "DAR=4 did not start/lock profile 0");
        end
        cfg_wr_addr = 12'h035;
        #1;
        if (cfg_wr_ready) begin
            $fatal(1, "loader writes to the profile being copied were not blocked");
        end
        cfg_wr_addr = 12'h400;
        #1;
        if (!cfg_wr_ready) begin
            $fatal(1, "loader was blocked from writing a different profile");
        end
        repeat (3) @(posedge clk);
        if (!cfg_rd_txn_start || !busy || read_count != 0) begin
            $fatal(1, "controller did not hold the request during bus backpressure");
        end
        @(negedge clk);
        read_gate = 1'b1;

        wait_for_load();
        if (read_count != 256) begin
            $fatal(1, "expected 256 reads for profile 0, got %0d", read_count);
        end
        if (!use_profile || decoded_word !== first_profile_word) begin
            $fatal(1, "profile 0 word packing/decode mismatch: got %h", decoded_word);
        end

        previous_read_count = read_count;
        repeat (4) @(posedge clk);
        if (read_count != previous_read_count) begin
            $fatal(1, "unchanged DAR unexpectedly reloaded its profile");
        end

        @(negedge clk);
        dar = 8'h05;
        wait_for_load();
        if (read_count != 512) begin
            $fatal(1, "expected 256 additional reads for profile 1, got %0d", read_count);
        end
        if (decoded_word !== second_profile_word) begin
            $fatal(1, "profile 1 opcode mapping mismatch: got %h", decoded_word);
        end

        @(negedge clk);
        dar = 8'h00;
        #1;
        if (busy || use_profile) begin
            $fatal(1, "returning to DAR=0 should select the built-in SEU ROM");
        end
        opcode = 8'h00;
        #1;
        if (decoded_word !== 31'h00002000) begin
            $fatal(1, "built-in SEU ROM behavior changed: got %h", decoded_word);
        end

        $display("SEU microcode profile tests passed");
        $finish;
    end
endmodule
