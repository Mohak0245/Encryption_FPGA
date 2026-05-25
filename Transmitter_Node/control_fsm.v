// Transmitter Control FSM

module control_fsm #(
    parameter MSG_LEN   = 9,
    parameter ADDR_BITS = 4
)(
    input  wire clk,
    input  wire rst,
    input  wire start_btn,
    input  wire enc_done,
    input  wire spi_ready,
    output reg rom_rd_en,
    output reg  [ADDR_BITS-1:0]  rom_addr,
    output reg enc_start,
    output reg tx_load,
    output reg spi_trigger
);

    // States
    localparam [3:0]
        S_IDLE        = 4'd0,
        S_ROM_READ    = 4'd1,
        S_WAIT_ROM    = 4'd2,
        S_ENCRYPT     = 4'd3,
        S_WAIT_ENC    = 4'd4,
        S_LOAD_TX     = 4'd5,
        S_TRIGGER_SPI = 4'd6,
        S_SPI_START   = 4'd7,   // 1-cycle gap before polling spi_ready
        S_WAIT_SPI    = 4'd8,
        S_NEXT        = 4'd9,
        S_DONE        = 4'd10;

    reg [3:0] state;
    reg [ADDR_BITS-1:0] byte_idx;

    always @(posedge clk) begin
        if (rst) begin
            state       <= S_IDLE;
            byte_idx    <= 0;
            rom_rd_en   <= 1'b0;
            rom_addr    <= 0;
            enc_start   <= 1'b0;
            tx_load     <= 1'b0;
            spi_trigger <= 1'b0;
        end else begin
            // Default: all pulse outputs set null
            rom_rd_en   <= 1'b0;
            enc_start   <= 1'b0;
            tx_load     <= 1'b0;
            spi_trigger <= 1'b0;

            case (state)

                S_IDLE: begin
                    byte_idx <= 0;
                    if (start_btn)
                        state <= S_ROM_READ;
                end

                S_ROM_READ: begin
                    rom_addr  <= byte_idx;
                    rom_rd_en <= 1'b1;
                    state     <= S_WAIT_ROM;
                end

                S_WAIT_ROM: begin
                    state <= S_ENCRYPT;
                end

                S_ENCRYPT: begin
                    enc_start <= 1'b1;
                    state     <= S_WAIT_ENC;
                end

                S_WAIT_ENC: begin
                    if (enc_done)
                        state <= S_LOAD_TX;
                end

                S_LOAD_TX: begin
                    tx_load <= 1'b1;
                    state   <= S_TRIGGER_SPI;
                end

                S_TRIGGER_SPI: begin
                    spi_trigger <= 1'b1;
                    state       <= S_SPI_START;  // go to buffer state
                end

                // One idle cycle
                S_SPI_START: begin
                    state <= S_WAIT_SPI;
                end

                S_WAIT_SPI: begin
                    if (spi_ready)
                        state <= S_NEXT;
                end

                S_NEXT: begin
                    if (byte_idx == (MSG_LEN - 1))
                        state <= S_DONE;
                    else begin
                        byte_idx <= byte_idx + 1'b1;
                        state    <= S_ROM_READ;
                    end
                end

                S_DONE: begin
                    state <= S_DONE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
