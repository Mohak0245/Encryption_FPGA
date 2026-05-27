// Receiver top module

//   Instantiates:
//   spi_slave: Receives message
//   receiver_fsm: Sequencing FSM
//   Decrypter: Decryption algorithm
//   output_buffer: Temporary storage to hold the entire decrypted message
//  External ports:
//    clk       - SYS_CLK_TX  (Board 2 oscillator)
//    rst       - RST_TX       (Board 2 button, active-high)
//    SCLK      - SPI clock output  (from Transmitter Board)
//    MOSI      - SPI data  output  (from Transmitter Board)
//    CS_bar    - SPI chip-select   (from Transmitter Board, active-low)
//    MISO      - SPI data  input   (to Transmitter Board)

module receiver_top #(
    parameter MSG_LEN = 9,
    parameter ADDR_BITS = 4
)(
    input wire clk,
    input wire rst,
    input wire SCLK,
    input wire MOSI,
    input wire CS_bar,
    output wire MISO
);
    // SPI Slave outputs
    wire data_ready;
    wire [7:0] received_data;

    // Receiver FSM outputs
    wire start_decryption;
    wire write_en;
    wire [ADDR_BITS-1:0] write_address;

    // decrypter outputs
    wire done;
    wire [7:0] data_out;

    // Module Instantiations
    
    // SPI Slave
    spi_slave u_spi_slave (
        .SCLK(SCLK),
        .rst(rst),
        .MOSI(MOSI),
        .CS_bar(CS_bar),
        .data_ready(data_ready),
        .received_data(received_data)
    );

    // Receiver Control FSM
    receiver_fsm #(
        .MSG_LEN(MSG_LEN),
        .ADDR_BITS(ADDR_BITS)
    ) u_receiver_fsm(
        .clk(clk),
        .rst(rst),
        .data_ready(data_ready),
        .done(done),
        .start_decryption(start_decryption),
        .write_en(write_en),
        .write_address(write_address),
        .MISO(MISO)
    );

    // Decrypter
    decrypter u_decrypter (
        .clk(clk),
        .rst(rst),
        .start(start_decryption),
        .data_in(received_data),
        .done(done),
        .data_out(data_out)
    );

    //Temporary Output Buffer
    output_buffer #(
        .MSG_LEN(MSG_LEN),
        .ADDR_BITS(ADDR_BITS)
    ) u_output_buffer(
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .write_address(write_address),
        .decrypted_data(data_out)
    );
    

endmodule