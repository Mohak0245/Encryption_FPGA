// ---------------------------------------------------------------------
//  transmitter_top.v
//  Transmitter Node Top Module
//
//  Instantiates:
//   rom: Message storage (loads data.mem)
//   control_fsm: Sequencing FSM
//   encrypter: Encryption algorithm
//   tx_register: 8-bit holding register between encrypter and SPI
//   spi_clock: SPI clock divider / enable-pulse generator
//   spi_master: SPI bit-bang transmitter
//
//  External ports:
//    clk       - SYS_CLK_TX  (Board 1 oscillator)
//    rst       - RST_TX       (Board 1 button, active-high)
//    start_btn - Start Button
//    SCLK      - SPI clock output  (to Receiver Board)
//    MOSI      - SPI data  output  (to Receiver Board)
//    CS_bar    - SPI chip-select   (to Receiver Board, active-low)
//    MISO      - SPI data  input   (from Receiver Board)
// ------------------------------------------------------------------

module transmitter_top #(
    parameter MSG_LEN   = 9,
    parameter ADDR_BITS = 4
)(
    input  wire clk,
    input  wire rst,
    input  wire start_btn,
    output wire SCLK,
    output wire MOSI,
    output wire CS_bar,
    input  wire MISO        // connect this to the receiver top module
);

    // adjust SPI clock speed
  localparam [7:0] FREQ_DIV = 8'd50;  // 50 MHz sys clk gives 1 MHz SCLK

    // internal wires
    // ROM - FSM
    wire rom_rd_en;
    wire [ADDR_BITS-1:0]  rom_addr;
    wire [7:0] rom_data_out;

    // FSM control pulses
    wire enc_start;
    wire tx_load;
    wire spi_trigger;

    // Encrypter
    wire [7:0] enc_data_out;
    wire enc_done;

    // TX Register - SPI Master
    reg  [7:0] tx_reg;

    // SPI Clock - SPI Master
    wire sclk_enable;
    wire enable_pulse;

    // SPI Master
    wire spi_ready;

    //  TX Register - Latches enc_data_out when FSM asserts tx_load
    always @(posedge clk) begin
        if (rst)
            tx_reg <= 8'h00;
        else if (tx_load)
            tx_reg <= enc_data_out;
    end

    //  Module Instantiations

    // ROM
    rom #(
        .MEM_DEPTH (MSG_LEN),
        .ADDR_BITS (ADDR_BITS)
    ) u_rom (
        .clk      (clk),
        .rd_en    (rom_rd_en),
        .addr     (rom_addr),
        .data_out (rom_data_out)
    );

    //Control FSM
    control_fsm #(
        .MSG_LEN   (MSG_LEN),
        .ADDR_BITS (ADDR_BITS)
    ) u_fsm (
        .clk        (clk),
        .rst        (rst),
        .start_btn  (start_btn),
        .enc_done   (enc_done),
        .spi_ready  (spi_ready),
        .rom_rd_en  (rom_rd_en),
        .rom_addr   (rom_addr),
        .enc_start  (enc_start),
        .tx_load    (tx_load),
        .spi_trigger(spi_trigger)
    );

    //  Encrypter
    encrypter u_enc (
        .clk      (clk),
        .rst      (rst),
        .start    (enc_start),
        .data_in  (rom_data_out),
        .data_out (enc_data_out),
        .done     (enc_done)
    );

    //SPI Clock
    spi_clock u_spi_clk (
        .clk         (clk),
        .freq_div    (FREQ_DIV),
        .rst         (rst),
        .sclk_enable (sclk_enable),
        .SCLK        (SCLK),
        .enable_pulse(enable_pulse)
    );

    //SPI Master
    spi_master u_spi (
        .clk            (clk),
        .encrypted_data (tx_reg),
        .encryption_done(spi_trigger),
        .enable_pulse   (enable_pulse),
        .rst            (rst),
        .CS_bar         (CS_bar),
        .MOSI           (MOSI),
        .sclk_enable    (sclk_enable),
        .ready          (spi_ready)
    );

endmodule
