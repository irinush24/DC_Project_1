module srt2 (
    input signed [7:0] Dividend,
    input signed [7:0] Divisor,
    output reg signed [7:0] Quotient,
    output reg error_div0
);
    reg [7:0] abs_num, abs_den;
    reg signed [8:0] R; // 9-bit Partial Remainder to track the sign bit
    reg [7:0] Q;        // Quotient register
    reg signed [8:0] D; // 9-bit Divisor
    reg sign_res;
    integer i;

    always @(Dividend or Divisor) begin
        // 1. Handle Division by Zero
        error_div0 = (Divisor == 8'd0);
        Quotient = 8'd0;

        if (!error_div0) begin
            // 2. Pre-processing: Determine signs and get absolute values
            sign_res = Dividend[7] ^ Divisor[7];
            abs_num = Dividend[7] ? -Dividend : Dividend;
            abs_den = Divisor[7]  ? -Divisor  : Divisor;

            // 3. Initialize Registers
            R = 9'd0;
            Q = abs_num;
            D = {1'b0, abs_den}; // Zero-extended to 9 bits for accurate signed math

            // 4. Unrolled Non-Restoring Radix-2 Loop
            for (i = 0; i < 8; i = i + 1) begin
                // Step A: Shift {R, Q} left by 1 bit
                R = {R[7:0], Q[7]};
                Q = Q << 1;

                // Step B: Add or Subtract based on the sign of Previous Remainder (R[8])
                if (R[8] == 1'b0) begin
                    // R is positive or zero
                    R = R - D;
                end else begin
                    // R is negative
                    R = R + D;
                end

                // Step C: Determine Quotient Digit
                if (R[8] == 1'b0) begin
                    Q[0] = 1'b1;
                end else begin
                    Q[0] = 1'b0;
                end
            end

            // 5. Apply Sign to Final Quotient
            Quotient = sign_res ? -Q : Q;
        end
    end
endmodule