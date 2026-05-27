module output_buffer #(
    parameter MSG_LEN = 9,
    parameter ADDR_BITS = 4
) (
    input wire clk,
    input wire rst,
    input wire write_en,
    input wire [ADDR_BITS-1:0] write_address,
    input wire [7:0] decrypted_data
    //input wire [ADDR_BITS-1:0] read_address,
    //output reg [7:0] output_data
    //these can be added later on if needed
);
    
    reg [7:0] mem_array [0:MSG_LEN-1];
    integer i;

    always@(posedge clk) begin
        if(rst) begin
            for (i = 0; i < MSG_LEN; i = i + 1) begin
                mem_array[i] <= 8'h00;
            end
        end else if(write_en) begin
            mem_array[write_address] <= decrypted_data;
        end
    end

endmodule