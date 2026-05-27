module spi_slave (
    input wire SCLK,
    input wire rst,
    input wire MOSI,
    input wire CS_bar,
    output reg data_ready,
    output reg [7:0] received_data
);

    reg [2:0] count; 

    always @(posedge SCLK or posedge rst) begin
        if(rst) begin
            received_data <= 0;
            data_ready <= 0;
            count <= 0;
        end
        else begin
            if(CS_bar) begin
                count <= 0;
                data_ready <= 0;
            end
            else begin
                data_ready <= 0;
                received_data[7 - count] <= MOSI;
                if(count == 3'b111) begin
                    count <= 0;
                    data_ready <= 1'b1;
                end else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

endmodule