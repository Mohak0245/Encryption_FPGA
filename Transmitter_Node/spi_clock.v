//Generates a slower SCLK which is used by the SPI Master and Slave

module spi_clock (
    input  wire clk,            
    input  wire [7:0] freq_div,   // Clock divider value
    input  wire rst,     
    input  wire sclk_enable,    
    output reg  SCLK,          
    output reg  enable_pulse    
);
    reg [7:0] freq_div_counter;   
    reg [7:0] freq_div_register; 
    wire [7:0] safe_freq_div = (freq_div < 8'd4) ? 8'd4 : {freq_div[7:1], 1'b0};

    always @(posedge clk) begin
        //Reset
        if(rst || !sclk_enable) begin
            SCLK <= 1'b0;    // Mode 0: Clock rests at 0
            freq_div_counter <= 8'h00;
            freq_div_register <= safe_freq_div;
            enable_pulse <= 1'b0;
        end
        else begin
            // Default pulse state is 0. Flashes high for 1 cycle when triggered.
            enable_pulse <= 1'b0; 
            
            // Toggle
            if(freq_div_counter == ((freq_div_register >> 1) - 1'b1)) begin
                freq_div_counter <= 8'h00;         
                SCLK <= ~SCLK;          
                freq_div_register <= safe_freq_div;       // update divider value if changed externally
                
                // if SCLK is currently 1 (about to flip to 0), fire the enable pulse exactly on the falling edge.
                if(SCLK == 1'b1) begin
                    enable_pulse <= 1'b1;
                end
            end
            else begin
                freq_div_counter <= freq_div_counter + 1'b1;
            end
        end
    end

endmodule