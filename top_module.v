//Final Top Module
//This module tells us about the connections between the two boards

module top_module #(
    parameter MSG_LEN = 9,
    parameter ADDR_BITS = 4
) (
    input wire clk_tx,
    input wire rst_tx,
    input wire start_btn,
    input wire clk_rx,
    input wire rst_rx
);

    wire MISO;
    wire SCLK;
    wire MOSI;
    wire CS_bar;

    transmitter_top #(
        .MSG_LEN (MSG_LEN),
        .ADDR_BITS (ADDR_BITS)
    ) u_transmitter_top(
        .clk(clk_tx),
        .rst(rst_tx),
        .start_btn(start_btn),
        .MISO(MISO),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .CS_bar(CS_bar)
    );

    receiver_top #(
        .MSG_LEN (MSG_LEN),
        .ADDR_BITS (ADDR_BITS)
    ) u_receiver_top(
        .clk(clk_rx),
        .rst(rst_rx),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .CS_bar(CS_bar),
        .MISO(MISO)
    );

endmodule