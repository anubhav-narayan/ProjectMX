module seu11_microcode_controller (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  dar,

    // MX-style 32-bit read master to the separate configuration store
    output logic        cfg_rd_txn_start,
    input  logic [31:0] cfg_rd_data,
    input  logic        cfg_rd_ready,
    output logic [9:0]  cfg_rd_addr,
    input  logic        cfg_rd_txn_ack,
    input  logic        cfg_rd_txn_cpl,

    output logic        busy,
    output logic        use_profile,
    output logic        cfg_profile_lock,
    output logic [1:0]  cfg_locked_profile,
    output logic        profile_wr_en,
    output logic [7:0]  profile_wr_addr,
    output logic [30:0] profile_wr_data
);

    typedef enum logic [1:0] {
        IDLE,
        REQUEST,
        WAIT_COMPLETE,
        GAP
    } load_state_t;

    load_state_t state;
    logic [7:0] dar_previous;
    logic [1:0] profile;
    logic [7:0] word_index;

    function automatic logic is_loadable_dar(input logic [7:0] value);
        is_loadable_dar = (value >= 8'h04) && (value <= 8'h07);
    endfunction

    function automatic logic [9:0] profile_base(input logic [1:0] value);
        case (value)
            2'd0: profile_base = 10'd0;
            2'd1: profile_base = 10'd256;
            2'd2: profile_base = 10'd512;
            2'd3: profile_base = 10'd768;
            default: profile_base = 10'd0;
        endcase
    endfunction

    wire profile_change_pending =
        (dar != dar_previous) && is_loadable_dar(dar);
    wire read_complete =
        ((state == REQUEST) && cfg_rd_ready && cfg_rd_txn_ack && cfg_rd_txn_cpl) ||
        ((state == WAIT_COMPLETE) && cfg_rd_txn_cpl);

    assign busy = (state != IDLE) || profile_change_pending;
    assign use_profile = is_loadable_dar(dar);
    assign cfg_profile_lock = busy;
    assign cfg_locked_profile = (state == IDLE) ? dar[1:0] : profile;

    assign cfg_rd_txn_start = (state == REQUEST);
    assign cfg_rd_addr = profile_base(profile) + {2'b00, word_index};
    assign profile_wr_en = read_complete;
    assign profile_wr_addr = word_index;
    assign profile_wr_data = cfg_rd_data[30:0];

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            dar_previous <= 8'h00;
            profile <= 2'b00;
            word_index <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    if (dar != dar_previous) begin
                        dar_previous <= dar;
                        if (is_loadable_dar(dar)) begin
                            profile <= dar[1:0];
                            word_index <= 8'h00;
                            state <= REQUEST;
                        end
                    end
                end
                REQUEST: begin
                    if (cfg_rd_ready && cfg_rd_txn_ack) begin
                        state <= cfg_rd_txn_cpl ? GAP : WAIT_COMPLETE;
                    end
                end
                WAIT_COMPLETE: begin
                    if (cfg_rd_txn_cpl) begin
                        state <= GAP;
                    end
                end
                GAP: begin
                    if (word_index == 8'hFF) begin
                        state <= IDLE;
                    end else begin
                        word_index <= word_index + 1'b1;
                        state <= REQUEST;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
