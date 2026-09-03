module mx11#(
    parameter integer IRQ_VECTOR = 8'hF0,
    parameter integer NMI_VECTOR = 8'h80
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
    enum logic [3:0] {
        ALU_BUF  = 4'h0,
        ALU_CLR  = 4'h1,
        ALU_NOT  = 4'h2,
        ALU_XOR  = 4'h3,
        ALU_AND  = 4'h4,
        ALU_OR   = 4'h5,
        ALU_INCR = 4'h8,
        ALU_DECR = 4'h9,
        ALU_ADD  = 4'hA,
        ALU_ADC  = 4'hB,
        ALU_SUB  = 4'hC,
        ALU_SBB  = 4'hD,
        ALU_CMP  = 4'hE
    } alu_ins, dex_alu_ins;

    // Mandatory Internal Registers
    logic [7:0] rta, rtf, insr;
    enum logic[7:0] {
        HALT,
        FETCH,
        DEX,
        IRQ_FETCH,
        IRQ_DEX,
        NMI_FETCH,
        NMI_DEX
    } mstate, mstate_next;
    reg nmi_r, irq_r;

    // Internal Wires
    wire fetch, fetch_done;
    wire irq_insr, nmi_insr, halt_insr, rti_insr;
    wire [7:0] flags_alu, flags_o;

    // Main Read Bus
    wire [3:0] m_rd_addr;
    wire [7:0] m_rd_data;

    // Main Write Bus
    wire [3:0] m_wr_addr;
    wire [7:0] m_wr_data;

    // Auxillary Read Bus
    wire [3:0] a_rd_addr;
    wire [7:0] a_rd_data;

    // Auxillary Write Bus
    wire [3:0] a_wr_addr;
    wire [7:0] a_wr_data;
    
    // Functions of Decoder
    mx11_decoder_rom inst_mx11_decoder_rom(
        .insr      (insr),
        .irq_insr  (irq_insr),
        .nmi_insr  (nmi_insr),
        .halt_insr (halt_insr),
        .rti_insr  (rti_insr),
        .ldi       (ldi),
        .m_rd_addr (dex_m_rd_addr),
        .a_rd_addr (dex_a_rd_addr),
        .m_wr_addr (dex_m_wr_addr),
        .alu_ins   (dex_alu_ins)
    );


    // SEU
    seu11 inst_seu11(
        .m_rd_data (m_rd_data),
        .a_rd_data (a_rd_data),
        .m_wr_data (m_wr_data),
        .a_wr_data (a_wr_data),
        .ldi       (ldi),
        .imm8      ({4'h0, insr[3:0]}),
        .alu_ins   (alu_ins),
        .flags_in  (flags_o),
        .flags     (flags_alu),
        .carry_in  (flags_o[0]),
        .carry_out ()
    );

    // Register File
    mxregs11 inst_mxregs11(
        .m_rd_addr (m_rd_addr),
        .m_rd_data (m_rd_data),
        .a_rd_addr (a_rd_addr),
        .a_rd_data (a_rd_data),
        .m_wr_addr (m_wr_addr),
        .m_wr_data (m_wr_data),
        .m_wr_le   (m_wr_le),
        .a_wr_addr (a_wr_addr),
        .a_wr_data (a_wr_data),
        .a_wr_le   (a_wr_le),
        .flags_i   (flags_i),
        .load_flags(load_flags),
        .flags_o   (flags_o),
        .clk       (clk),
        .rst       (rst)
    );

    // Instruction Fetch
    assign fetch = (mstate==FETCH) || (mstate==NMI_FETCH) || (mstate==IRQ_FETCH);
    mx11_ins_fetch #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(8)
    ) inst_mx11_ins_fetch (
        .insp             (m_rd_data),
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


    always_ff @(posedge clk) begin : main_fsm
        if (rst) begin
            mstate <= FETCH;
            nmi_r <= 1'b0;
            irq_r <= 1'b0;
        end else begin
            mstate <= mstate_next;
            if (nmi || nmi_insr) begin
                // If there is an NMI signal or the current instruction is an NMI instruction, set the NMI pending flag
                nmi_r <= 1'b1;
            end
            if (irq || irq_insr) begin
                // If there is an IRQ signal or the current instruction is an IRQ instruction, set the IRQ pending flag
                irq_r <= 1'b1;
            end
            if (rti_insr) begin
                // If the current instruction is an RTI instruction, clear the interrupt pending flags
                nmi_r <= 1'b0;
                irq_r <= 1'b0;
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
        load_flags = 1'b0;
        alu_ins = ALU_BUF;
        flags_i = 7'h0;
        case (mstate)
            FETCH: begin
                if (fetch_done) begin
                    // Go to DEX to decode and execute the instruction.
                    mstate_next = DEX;
                    m_rd_addr = 4'h6; // Read Address INSP(0x6)
                    m_wr_addr = 4'h6; // Write Address INSP(0x6)
                    m_wr_le = 1'b1; // Load INCR INSP into INSP
                    alu_ins = ALU_INCR; // ALU operation to increment INSP
                end else begin
                    mstate_next = FETCH;
                end
            end
            DEX: begin
                if (nmi_r) begin  // Check if there was an NMI, service that first
                    mstate_next = NMI_FETCH;
                end else if (irq_r) begin // Check if there was an IRQ, if so service that next
                    mstate_next = IRQ_FETCH;
                end else if (halt_insr) begin // Check if the instruction is HALT, if so stay in HALT state until an interrupt occurs
                    mstate_next = HALT;
                end else begin  // Normal instruction execution path
                    m_wr_addr = dex_m_wr_addr;
                    m_rd_addr = dex_m_rd_addr;
                    a_wr_addr = 4'h7;
                    a_rd_addr = dex_a_rd_addr;
                    m_wr_le = 1'b1;
                    a_wr_le = 1'b1;
                    alu_ins = dex_alu_ins;
                    mstate_next = FETCH;
                end
            end
            HALT: begin
                if (nmi_r) begin  // Check if there was an NMI, service that first
                    // In HALT, NMI is the normal path to execute and not an interrupt.
                    mstate_next = FETCH;
                end else begin  // Stay in HALT state until an interrupt occurs
                    mstate_next = HALT;
                end
            end
            IRQ_FETCH: begin
                // Save current INSP to RTA
                // Save current Flags to RTF
                // Load INSP with IRQ_VECTOR
                if (fetch_done) begin
                    m_rd_addr = 4'h6; // Read Address INSP(0x6)
                    m_wr_addr = 4'h6; // Write Address INSP(0x6)
                    m_wr_le = 1'b1; // Load INCR INSP into INSP
                    alu_ins = ALU_INCR; // ALU operation to increment INSP
                    mstate_next = IRQ_DEX; 
                end else begin
                    mstate_next = IRQ_FETCH; 
                end
            end
            IRQ_DEX: begin
                if (nmi_r) begin  // Check if there was an NMI, service that first
                    // Set Interrupt Disable Flag, Save INSP and Flags to RTA and RTF
                    // Load INSP with NMI_VECTOR
                    mstate_next = NMI_FETCH;
                end else if(rti_insr) begin // Check if the instruction is RTI, if so return from interrupt
                    // Clear Interrupt Disable Flag,
                    // Restore INSP from RTA
                    // Restore Flags from RTF
                    mstate_next = FETCH;
                end else if (halt_insr) begin // Check if the instruction is HALT, if so stay in HALT state until an interrupt occurs
                    mstate_next = HALT;
                end else begin  // Normal instruction execution path for instructions following an IRQ
                    m_wr_addr = dex_m_wr_addr;
                    m_rd_addr = dex_m_rd_addr;
                    a_wr_addr = 4'h7;
                    a_rd_addr = dex_a_rd_addr;
                    m_wr_le = 1'b1;
                    a_wr_le = 1'b1;
                    alu_ins = dex_alu_ins;
                    mstate_next = IRQ_FETCH;
                end
            end
            NMI_FETCH: begin
                // Save current INSP to RTA
                // Save current Flags to RTF
                // Load INSP with NMI_VECTOR
                if (fetch_done) begin
                    m_rd_addr = 4'h6; // Read Address INSP(0x6)
                    m_wr_addr = 4'h6; // Write Address INSP(0x6)
                    m_wr_le = 1'b1; // Load INCR INSP into INSP
                    alu_ins = ALU_INCR; // ALU operation to increment INSP
                    mstate_next = NMI_DEX; 
                end else begin
                    mstate_next = NMI_FETCH;
                end
            end
            NMI_DEX: begin
                if(rti_insr) begin // Check if the instruction is RTI, if so return from interrupt
                    // Clear Interrupt Disable Flag,
                    // Restore INSP from RTA
                    // Restore Flags from RTF
                    mstate_next = FETCH;
                end else if (halt_insr) begin // Check if the instruction is HALT, if so stay in HALT state until an interrupt occurs
                    mstate_next = HALT;
                end else begin  // Normal instruction execution path for instructions following an NMI
                    m_wr_addr = dex_m_wr_addr;
                    m_rd_addr = dex_m_rd_addr;
                    a_wr_addr = 4'h7;
                    a_rd_addr = dex_a_rd_addr;
                    m_wr_le = 1'b1;
                    a_wr_le = 1'b1;
                    mstate_next = NMI_FETCH;
                end
            end
        endcase
    end


endmodule