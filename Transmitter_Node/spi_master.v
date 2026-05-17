// Transmits 8 bits of data over MOSI using SPI Mode 0.
// Order of bit transmission: MSB to LSB.

module spi_master (
    input  wire clk,             
    input  wire [7:0] encrypted_data, 
    input  wire encryption_done,  
    input  wire enable_pulse,     
    input  wire rst,            
    output reg CS_bar,       
    output reg MOSI,            
    output reg sclk_enable,   
    output reg ready             
);
    reg [3:0] count; 
    reg [7:0] data_register; // Internal holding register for the byte

    always @(posedge clk) begin
        //Reset
        if(rst) begin
            CS_bar <= 1'b1;   
            MOSI <= 1'b0;   
            count <= 4'b0000;
            data_register <= 8'h00;
            sclk_enable <= 1'b0;   
            ready <= 1'b1;
        end
        else begin
            //Start Condition
            if(encryption_done && CS_bar) begin
                CS_bar <= 1'b0;             
                data_register <= encrypted_data;    
                MOSI <= encrypted_data[7]; // Pre-load Bit 7 instantly
                count <= 4'b0001;
                sclk_enable <= 1'b1; 
                ready <= 1'b0;
            end
            
       
            else if(!CS_bar && enable_pulse) begin
                //Bit Shifting
                if(count <= 4'b0111) begin
                    MOSI <= data_register[7 - count];
                    count <= count + 1'b1;
                end
                //Cleanup
                else begin
                    CS_bar <= 1'b1;
                    MOSI <= 1'b0;
                    sclk_enable <= 1'b0;
                    count <= 4'b0000;   
                    ready <= 1'b1;      
                end
            end
        end
    end

endmodule