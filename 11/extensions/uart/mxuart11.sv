module mx_uart_11 (
    // MX/11 main register-file read and write buses
    output logic [3:0] m_rd_addr,
    input  logic [7:0] m_rd_data,
    output logic [3:0] m_wr_addr,
    output logic [7:0] m_wr_data,
    output logic       m_wr_le,

    // UART controls are supplied by the extension decoder.
    input logic [7:0] opcode,
    input logic       uart_ce,

    // UART signals
    input  logic       uart_rx,
    output logic       uart_tx,
    input  logic       uart_irq,

    // UART CLK & RST
    input  logic       uart_clk,
    input  logic       uart_rst,

    // CLK & RST
    input  logic       clk,
    input  logic       rst
);
/*
MNEMONIC | OPCODE | DESCRIPTION
---------+--------+---------------------------------------------------
RXBUF reg | 0x00-0x0F | Read the UART receive buffer register (RXBUF) into the main register file.
TXBUF reg | 0x10-0x1F | Write the main register file data to the UART transmit buffer register (TXBUF).
STATUS    | 0x20      | Read the UART status register into A.
CLRSTATUS | 0x21      | Clear the UART status register.

STATUS register bits:
Bit 7: RXRDY (Receive Ready) - Set when data is available in the receive buffer.
Bit 6: TXRDY (Transmit Ready) - Set when the transmit buffer is ready to accept new data.
Bit 5: PARITY_ERR - Set when a parity error has occurred in the received data.
Bit 4: FRAMING_ERR - Set when a framing error has occurred in the received data.
Bit 3: OVERRUN_ERR - Set when an overrun error has occurred in the receive buffer.
Bit 2: BREAK_DETECT - Set when a break condition has been detected on the receive line.
Bit 1: CTS (Clear to Send) - Set when the Clear to Send signal is asserted.
Bit 0: DSR (Data Set Ready) - Set when the Data Set Ready signal is asserted.
*/

endmodule : mx_uart_11