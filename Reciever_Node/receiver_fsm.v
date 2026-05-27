// Transmitter Control FSM

module receiver_fsm  #(
    parameter MSG_LEN = 9,
    parameter ADDR_BITS = 4
)(
    input wire clk,
    input wire rst,
    input wire data_ready,
    input wire done,
    output reg start_decryption,
    output reg write_en,
    output reg [ADDR_BITS-1:0] write_address,
    output reg MISO
);

//States
    localparam [2:0]
        S_IDLE = 3'd0,
        S_SPI_RECEIVING = 3'd1, 
        S_WAIT_DEC = 3'd2,
        S_BUFFERING = 3'd3,
        S_NEXT = 3'd4,
        S_DONE = 3'd5;

    reg [2:0] state;
    reg [ADDR_BITS-1:0] byte_idx; //temporary address counter


//Using the data_ready pulse directly in the FSM causes issues because that is fired in sync with the slow SPI clock
    reg data_ready_meta;
    reg data_ready_sync;
    reg data_ready_prev;
    wire data_ready_pulse;

    assign data_ready_pulse = data_ready_sync & ~data_ready_prev;

    always @(posedge clk) begin
        if (rst) begin
            data_ready_meta <= 1'b0;
            data_ready_sync <= 1'b0;
            data_ready_prev <= 1'b0;
        end else begin
            data_ready_meta <= data_ready;       
            data_ready_sync <= data_ready_meta;  
        
            data_ready_prev <= data_ready_sync; //Stores the previous cycle's value
        end
    end
//This code creates a new pulse which is in sync with the system clock, ensuring the FSM functions optimally.


    always @(posedge clk) begin
        if(rst) begin
            start_decryption <= 0;
            MISO <= 0;
            byte_idx <= 0;
            write_en <= 0;
            write_address <= 0;
            state <= S_IDLE;
        end else begin

            // Default: all pulse outputs set null

            start_decryption <= 0;
            MISO <= 0;
            write_en <= 0;

            case (state)

                S_IDLE: begin
                    start_decryption <= 0;
                    MISO <= 0;
                    byte_idx <= 0;
                    write_en <= 0;
                    write_address <= 0;
                    state <= S_SPI_RECEIVING;
                end

                S_SPI_RECEIVING: begin
                    if(data_ready_pulse) begin
                        start_decryption <= 1'b1;
                        state <= S_WAIT_DEC;
                    end
                end

                S_WAIT_DEC: begin
                    if(done) begin
                        write_en <= 1'b1;
                        write_address <= byte_idx;
                        state <= S_BUFFERING;
                    end
                end

                S_BUFFERING: begin
                    state <= S_NEXT;
                end

                S_NEXT:begin
                    if(byte_idx == (MSG_LEN-1)) begin
                        state <= S_DONE;
                    end else begin
                        byte_idx <= byte_idx + 1'b1;
                        state <= S_SPI_RECEIVING;
                    end
                end

                S_DONE: begin
                    MISO <= 1'b1;
                    state <= S_DONE;
                end

                default: begin 
                    state <= S_IDLE;
                end

            endcase
        end
    end

endmodule