module mx11_71#(
    parameter logic [7:0] IRQ_VECTOR = 8'hC0,
    parameter logic [7:0] NMI_VECTOR = 8'h80
)(
    // MX Bus Read Master Instruction
    output  wire       ins_rd_txn_start,
     input  wire [7:0] ins_rd_data,
     input  wire       ins_rd_ready,
    output  wire [7:0] ins_rd_addr,
     input  wire       ins_rd_txn_ack,
     input  wire       ins_rd_txn_cpl,

    // MX Bus Write Master Data
    output  wire       data_wr_txn_start,
    output  wire [7:0] data_wr_data,
     input  wire       data_wr_ready,
    output  wire [7:0] data_wr_addr,
     input  wire       data_wr_txn_ack,
     input  wire       data_wr_txn_cpl,
    
    // MX Bus Read Master Data
    output  wire       data_rd_txn_start,
     input  wire [7:0] data_rd_data,
     input  wire       data_rd_ready,
    output  wire [7:0] data_rd_addr,
     input  wire       data_rd_txn_ack,
     input  wire       data_rd_txn_cpl,

    // Interrupt
     input  wire nmi,
     input  wire irq,

    // CLK & RST
     input  wire clk,
     input  wire rst
);

    // ALU opcode constants
    localparam logic [3:0] ALU_BUF  = 4'h0;
    localparam logic [3:0] ALU_CLR  = 4'h1;
    localparam logic [3:0] ALU_NOT  = 4'h2;
    localparam logic [3:0] ALU_XOR  = 4'h3;
    localparam logic [3:0] ALU_AND  = 4'h4;
    localparam logic [3:0] ALU_OR   = 4'h5;
    localparam logic [3:0] ALU_INCR = 4'h8;
    localparam logic [3:0] ALU_DECR = 4'h9;
    localparam logic [3:0] ALU_ADD  = 4'hA;
    localparam logic [3:0] ALU_ADC  = 4'hB;
    localparam logic [3:0] ALU_SUB  = 4'hC;
    localparam logic [3:0] ALU_SBB  = 4'hD;
    localparam logic [3:0] ALU_CMP  = 4'hE;
    logic [3:0] alu_ins;

    // Mandatory Internal Registers
    logic [7:0] rta, rtf, insr, rtd;
    typedef enum logic [3:0] {
        FETCH             = 4'd0,
        POST              = 4'd1,
        DEX               = 4'd2,
        LOAD_STORE        = 4'd3,
        HALT              = 4'd4,
        INT_ENTRY         = 4'd5,
        INT_VECTOR        = 4'd6,
        RTI_RESTORE_INSP    = 4'd7,
        RTI_RESTORE_DAR   = 4'd8,
        RTI_RESTORE_FLAGS = 4'd9
    } mstate_t;
    mstate_t mstate, mstate_next;

    typedef enum logic [1:0] {
        NO_INTERRUPT = 2'd0,
        IRQ_SERVICE  = 2'd1,
        NMI_SERVICE  = 2'd2
    } interrupt_mode_t;
    interrupt_mode_t interrupt_mode, interrupt_mode_next;
    logic m_wr_le, a_wr_le, ldi;
    logic [7:0] imm8;
    reg nmi_r, irq_r;
    logic [7:0] insp_r, dar_r;

    // Internal Wires
    logic fetch, fetch_done;
    logic irq_insr, nmi_insr, halt_insr, rti_insr;
    logic unserviced_nmi, unserviced_irq;
    logic [7:0] flags_alu, flags_o;

    // Main Read Bus
    logic [3:0] m_rd_addr;
    logic [7:0] m_rd_data;

    // Main Write Bus
    logic [3:0] m_wr_addr;
    logic [7:0] m_wr_data;

    // Auxillary Read Bus
    logic [3:0] a_rd_addr;
    logic [7:0] a_rd_data;

    // Auxillary Write Bus
    logic [3:0] a_wr_addr;
    logic [7:0] a_wr_data;

    typedef struct packed {
        logic       ldi;
        logic [7:0] imm8;
        logic [3:0] m_rd_addr;
        logic [3:0] a_rd_addr;
        logic       m_wr_le;
        logic [3:0] m_wr_addr;
        logic       a_wr_le;
        logic [3:0] a_wr_addr;
        logic [3:0] alu_ins;
    } insr_t;

    typedef struct packed {
        logic [7:0] m_wr_data;
        logic [7:0] a_wr_data;
    } wr_t;

    // Decode-Execute (DEX) Instruction Wires
    insr_t dex_insr;
    wr_t main_wr;
    
    // SYS Wirings
    insr_t sys_insr;

    // SEU Wirings
    insr_t seu_insr;
    wr_t seu_wr;

    // Shifter Wirings
    insr_t shifter_insr;
    wr_t shifter_wr;
    
    // SYS Decoder
    mx11_sys_rom sys_rom (
        .insr(insr[3:0]),
        .ldi(sys_insr.ldi),
        .imm8(sys_insr.imm8),
        .m_rd_addr(sys_insr.m_rd_addr),
        .a_rd_addr(sys_insr.a_rd_addr),
        .m_wr_le(sys_insr.m_wr_le),
        .m_wr_addr(sys_insr.m_wr_addr),
        .a_wr_le(sys_insr.a_wr_le),
        .a_wr_addr(sys_insr.a_wr_addr),
        .alu_ins(sys_insr.alu_ins)
    );

    // SEU Decoder
    seu11_rom seu_rom (
        .insr(insr),
        .ldi(seu_insr.ldi),
        .imm8(seu_insr.imm8),
        .m_rd_addr(seu_insr.m_rd_addr),
        .a_rd_addr(seu_insr.a_rd_addr),
        .m_wr_le(seu_insr.m_wr_le),
        .m_wr_addr(seu_insr.m_wr_addr),
        .a_wr_le(seu_insr.a_wr_le),
        .a_wr_addr(seu_insr.a_wr_addr),
        .alu_ins(seu_insr.alu_ins)
    );

    always_comb begin
        if (insr[7]) begin
            dex_insr = sys_insr;
            main_wr = seu_wr;
        end else begin
            case (dar_r)
                8'h01: begin // DAR = 0x01 -> MXSHIFT/11 instruction
                    dex_insr = shifter_insr;
                    main_wr = shifter_wr;
                end
                default: begin
                    dex_insr = seu_insr;
                    main_wr = seu_wr;
                end 
            endcase
        end
    end
    assign irq_insr = (insr == 8'hF6);
    assign nmi_insr = (insr == 8'hFE);
    assign rti_insr = (insr == 8'hF7);
    assign halt_insr = (insr == 8'hFF);
    // Keep NMIs pending during an active handler; FETCH accepts them after RTI.
    assign unserviced_nmi = nmi_r && (interrupt_mode == NO_INTERRUPT);
    assign unserviced_irq = irq_r && (interrupt_mode == NO_INTERRUPT) && !flags_o[7];

    // Instruction Fetch
    assign fetch = (mstate == FETCH) && !unserviced_nmi && !unserviced_irq;
    mx11_ins_fetch inst_mx11_ins_fetch (
        .insp             (insp_r),
        .ins_rd_txn_start (ins_rd_txn_start),
        .ins_rd_data      (ins_rd_data),
        .ins_rd_ready     (ins_rd_ready),
        .ins_rd_addr      (ins_rd_addr),
        .ins_rd_txn_ack   (ins_rd_txn_ack),
        .ins_rd_txn_cpl   (ins_rd_txn_cpl),
        .fetch            (fetch),
        .insr             (insr),
        .fetch_done       (fetch_done),
        .clk              (clk),
        .rst              (rst)
    );

    // LSU Control Signals
    wire store_ready, load_ready;
    wire store, load;
    wire store_valid, load_valid;
    wire [7:0] lsu_rd_data;

    assign store = (insr == 8'hFD);
    assign load = (insr == 8'hFC);

    // LSU
    mx11_lsu #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(8)
    ) inst_mx11_lsu (
        .data_rd_txn_start(data_rd_txn_start),
        .data_rd_txn_ack  (data_rd_txn_ack),
        .data_rd_txn_cpl  (data_rd_txn_cpl),
        .data_rd_addr     (data_rd_addr),
        .data_rd_data     (data_rd_data),
        .data_rd_ready    (data_rd_ready),
        .data_wr_txn_start(data_wr_txn_start),
        .data_wr_txn_ack  (data_wr_txn_ack),
        .data_wr_txn_cpl  (data_wr_txn_cpl),
        .data_wr_addr     (data_wr_addr),
        .data_wr_data     (data_wr_data),
        .data_wr_ready    (data_wr_ready),
        .rd_addr          (m_rd_data),
        .rdata            (lsu_rd_data),
        .load_ready       (load_ready),
        .load             (load),
        .load_valid       (load_valid),
        .wr_addr          (m_rd_data),
        .wdata            (a_rd_data),
        .store_ready      (store_ready),
        .store            (store),
        .store_valid      (store_valid),
        .clk              (clk),
        .rst              (rst) 
    );

    // MXALU/11
    seu11 inst_seu11 (
        .m_rd_data(m_rd_data),
        .a_rd_data(a_rd_data),
        .m_wr_data(seu_wr.m_wr_data),
        .a_wr_data(seu_wr.a_wr_data),
        .ldi(ldi),
        .imm8(imm8),
        .alu_ins(alu_ins),
        .flags_in(flags_o),
        .flags(flags_alu),
        .carry_in(flags_o[1]),
        .carry_out()
    );

    // MXSHIFT/11 + Decoder
    mx11bshift inst_mx11bshift (
        .m_rd_addr(shifter_insr.m_rd_addr),
        .m_rd_data(m_rd_data),
        .m_wr_addr(shifter_insr.m_wr_addr),
        .m_wr_data(shifter_wr.m_wr_data),
        .m_wr_le(shifter_insr.m_wr_le),
        .opcode(insr[7:0]),
        .bs_ce(dar_r == 8'h01)
    );

    // Register File
    mxregs11 inst_mxregs11 (
        .m_rd_addr(m_rd_addr),
        .m_rd_data(m_rd_data),
        .a_rd_addr(a_rd_addr),
        .a_rd_data(a_rd_data),
        .m_wr_addr(m_wr_addr),
        .m_wr_data(main_wr.m_wr_data),
        .m_wr_le(m_wr_le),
        .a_wr_addr(a_wr_addr),
        .a_wr_data(main_wr.a_wr_data),
        .a_wr_le(a_wr_le),
        .reg_flags(flags_o),
        .reg_insp(insp_r),
        .reg_dar(dar_r),
        .nmi(nmi_r),
        .irq(irq_r),
        .insp_wr_le(1'b0),
        .insp_wr_data(8'h00),
        .clk(clk),
        .rst(rst)
    );


    always_ff @(posedge clk) begin : main_fsm
        if (rst) begin
            mstate <= FETCH;
            interrupt_mode <= NO_INTERRUPT;
            nmi_r <= 1'b0;
            irq_r <= 1'b0;
            rta <= 8'h00;
            rtf <= 8'h00;
            rtd <= 8'h00;
        end else begin
            mstate <= mstate_next;
            interrupt_mode <= interrupt_mode_next;
            if (nmi || nmi_insr) begin
                // If there is an NMI signal or the current instruction is an NMI instruction, set the NMI pending flag
                nmi_r <= 1'b1;
            end
            if (irq || irq_insr) begin
                // If there is an IRQ signal or the current instruction is an IRQ instruction, set the IRQ pending flag
                irq_r <= 1'b1;
            end
            if (mstate == INT_ENTRY) begin
                rta <= insp_r;
                rtf <= flags_o;
                rtd <= dar_r;
                if (interrupt_mode == NMI_SERVICE) begin
                    nmi_r <= 1'b0;
                end else if (interrupt_mode == IRQ_SERVICE) begin
                    irq_r <= 1'b0;
                end
            end
        end
    end

    always_comb begin : transition_delta
        // Default values for outputs and next state
        m_wr_addr = 4'h0;
        m_wr_le = 1'b0;
        m_rd_addr = 4'h0;
        a_wr_addr = 4'h0;
        a_wr_le = 1'b0;
        a_rd_addr = 4'h0;
        ldi = 1'b0;
        imm8 = 8'h00;
        alu_ins = ALU_BUF;
        mstate_next = mstate;
        interrupt_mode_next = interrupt_mode;
        case (mstate)
            FETCH: begin
                if (unserviced_nmi) begin
                    mstate_next = INT_ENTRY;
                    interrupt_mode_next = NMI_SERVICE;
                end else if (unserviced_irq) begin
                    mstate_next = INT_ENTRY;
                    interrupt_mode_next = IRQ_SERVICE;
                end else if (fetch_done) begin
                    // Go to POST for INSP increment and then to DEX for instruction decode and execution.
                    mstate_next = POST;
                    m_rd_addr = 4'h6; // Read Address INSP(0x6)
                    m_wr_addr = 4'h6; // Write Address INSP(0x6)
                    m_wr_le = 1'b1; // Load INCR INSP into INSP
                    alu_ins = ALU_INCR; // ALU operation to increment INSP
                end else begin
                    mstate_next = FETCH;
                end
            end
            POST: begin
                // Go to DEX to decode and execute the instruction.
                mstate_next = DEX;
            end
            DEX: begin
                if (halt_insr) begin // Check if the instruction is HALT, if so stay in HALT state until an interrupt occurs
                    mstate_next = HALT;
                end else begin  // Normal instruction execution path
                    ldi = dex_insr.ldi;
                    imm8 = dex_insr.imm8;
                    m_wr_addr = dex_insr.m_wr_addr;
                    m_rd_addr = dex_insr.m_rd_addr;
                    a_wr_addr = dex_insr.a_wr_addr;
                    a_rd_addr = dex_insr.a_rd_addr;
                    m_wr_le = dex_insr.m_wr_le;
                    a_wr_le = dex_insr.a_wr_le;
                    alu_ins = dex_insr.alu_ins;
                    if (rti_insr) begin
                        mstate_next = (interrupt_mode == NO_INTERRUPT) ? FETCH : RTI_RESTORE_INSP;
                    end else if (load) begin
                        mstate_next = load_ready ? LOAD_STORE : DEX;
                    end else if (store) begin
                        mstate_next = store_ready ? LOAD_STORE : DEX;
                    end else begin
                        mstate_next = FETCH;
                    end
                end
            end
            LOAD_STORE: begin
                if ((load_valid) | (store_valid)) begin
                    mstate_next = FETCH;
                end else begin
                    mstate_next = LOAD_STORE;
                end
            end
            HALT: begin
                if (nmi_r) begin
                    mstate_next = FETCH;
                end else begin  // Stay in HALT state until an NM interrupt occurs
                    mstate_next = HALT;
                end
            end
            // Interrupt entry/exit preserves context and gives NMI priority over IRQ.
            INT_ENTRY: begin
                mstate_next = INT_VECTOR;
            end
            INT_VECTOR: begin
                ldi = 1'b1;
                imm8 = (interrupt_mode == NMI_SERVICE) ? NMI_VECTOR[7:0] : IRQ_VECTOR[7:0];
                m_wr_addr = 4'h6;
                m_wr_le = 1'b1;
                mstate_next = FETCH;
            end
            RTI_RESTORE_INSP: begin
                ldi = 1'b1;
                imm8 = rta;
                m_wr_addr = 4'h6;
                m_wr_le = 1'b1;
                mstate_next = RTI_RESTORE_DAR;
            end
            RTI_RESTORE_DAR: begin
                ldi = 1'b1;
                imm8 = rtd;
                m_wr_addr = 4'h5;
                m_wr_le = 1'b1;
                mstate_next = RTI_RESTORE_FLAGS;
            end
            RTI_RESTORE_FLAGS: begin
                ldi = 1'b1;
                imm8 = rtf;
                m_wr_addr = 4'h7;
                m_wr_le = 1'b1;
                interrupt_mode_next = NO_INTERRUPT;
                mstate_next = FETCH;
            end
            default: begin
                mstate_next = FETCH;
                interrupt_mode_next = NO_INTERRUPT;
            end
        endcase
    end


endmodule