// =============================================================
//  decrypter.v
//  8-bit Decryption Module
//
//  Encryption Algorithm (exact reverse of encrypter):
//  1. NOT
//  2. Circular Right Shift 3
//  3. SUB  Key B  (8'h8C)  [mod 256]
//  4. XOR  with Key C (8'h55)
//  5. NOT
//  6. Circular Right Shift 3
//  7. SUB  Key B  (8'h8C)  [mod 256]
//  8. XOR  with Key A (8'h1F)
//  9. Bit Reversal
//
//  Ports:
//  clk - clock (rising edge trigger)
//  rst - synchronous active-high reset
//  start - assert for 1 cycle to begin decryption
//  data_in - 8-bit ciphertext input
//  data_out - 8-bit plaintext output
//  done - pulses high for 1 cycle when data_out is valid
// =============================================================

module decrypter (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [7:0] data_in,
    output reg  [7:0] data_out,
    output reg done
);

    // Key constants
    localparam [7:0] KEY_A = 8'h1F;
    localparam [7:0] KEY_B = 8'h8C;
    localparam [7:0] KEY_C = 8'h55;

    // Pipeline wires
    wire [7:0] s1, s2, s3, s4, s5, s6, s7, s8, s9;

    // Decryption process
    assign s1 = ~data_in;
    assign s2 = { s1[2:0], s1[7:3] };
    assign s3 = s2 - KEY_B;
    assign s4 = s3 ^ KEY_C;
    assign s5 = ~s4;
    assign s6 = { s5[2:0], s5[7:3] };
    assign s7 = s6 - KEY_B;
    assign s8 = s7 ^ KEY_A;
    assign s9 = {s8[0], s8[1], s8[2], s8[3], s8[4], s8[5], s8[6], s8[7]};

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
