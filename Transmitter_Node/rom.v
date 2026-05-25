//  Synchronous ROM module for message storage
module rom #(
    parameter MEM_DEPTH = 9, // number of bytes in message
    parameter ADDR_BITS = 4
)(
    input  wire clk,
    input  wire rd_en,
    input  wire [ADDR_BITS-1:0]  addr,
    output reg  [7:0] data_out
);
    reg [7:0] mem [0:MEM_DEPTH-1];

    initial begin
        $readmemh("data.mem", mem);
    end

    always @(posedge clk) begin
        if (rd_en)
            data_out <= mem[addr];
    end

endmodule
