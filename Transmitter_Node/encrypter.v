// =============================================================
//  encrypter.v
//  8-bit Encryption Module
//
//  Encryption Algorithm:
//  1. Bit Reversal
//  2. XOR  with Key A (8'h1F)
//  3. ADD  Key B (8'h8C)  (mod 256 - discard carry bit)
//  4. Circular Left Shift 3
//  5. Bitwise NOT (Inverter)
//  6. XOR  with Key C (8'h55)
//  7. ADD  Key B (8'h8C)  (mod 256 - discard carry bit)
//  8. Circular Left Shift 3
//  9. Bitwise NOT (Inverter)
//
//  Ports:
//  clk - clock (rising edge trigger)
//  rst - synchronous active-high reset
//  start - asserted for 1 cycle to begin encryption
//  data_in - 8-bit data input (ASCII values)
//  data_out - 8-bit encrypted output
//  done - pulses high for 1 cycle when data_out is valid
// =============================================================

module encrypter (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [7:0] data_in,
    output reg [7:0] data_out,
    output reg done
);

    // Key constants
    localparam [7:0] KEY_A = 8'h1F;
    localparam [7:0] KEY_B = 8'h8C;
    localparam [7:0] KEY_C = 8'h55;

    // Pipeline steps wires
    wire [7:0] s1, s2, s3, s4, s5, s6, s7, s8, s9;

    // Encryption process
    assign s1 = {data_in[0], data_in[1], data_in[2], data_in[3], data_in[4], data_in[5], data_in[6], data_in[7]};
    assign s2 = s1 ^ KEY_A;
    assign s3 = s2 + KEY_B;
    assign s4 = {s3[4:0], s3[7:5]};
    assign s5 = ~s4;
    assign s6 = s5 ^ KEY_C;
    assign s7 = s6 + KEY_B;
    assign s8 = {s7[4:0], s7[7:5]};
    assign s9 = ~s8;

    always @(posedge clk) begin
        if (rst) begin
            data_out <= 8'h00;
            done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (start) begin
                data_out <= s9;
                done <= 1'b1;
            end
        end
    end

endmodule
