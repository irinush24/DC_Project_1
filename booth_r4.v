module booth_r4 (
    input signed [7:0] A,
    input signed [7:0] B,
    output reg signed [15:0] Prod
);
    reg signed [15:0] M;
    reg signed [15:0] M_neg;
    reg signed [15:0] M_2;
    reg signed [15:0] M_neg2;
    reg [8:0] B_ext; // B padded with a 0 on the right
    integer i;
    reg [2:0] booth_sel; // Register to hold the 3 extracted bits

    always @(A or B) begin
        M = {{8{A[7]}}, A};           // Sign extended A
        M_neg = -M;                   // -A
        M_2 = M << 1;                 // 2A
        M_neg2 = -M_2;                // -2A
        B_ext = {B, 1'b0};
        Prod = 16'd0;

        for (i = 0; i < 8; i = i + 2) begin
            // FIX: Shift right by 'i' and mask the bottom 3 bits.
            // This is universally supported and avoids all bounded-range errors.
            booth_sel = (B_ext >> i) & 3'b111;
            
            case (booth_sel)
                3'b000, 3'b111: Prod = Prod + 16'd0;
                3'b001, 3'b010: Prod = Prod + (M <<< i);
                3'b011:         Prod = Prod + (M_2 <<< i);
                3'b100:         Prod = Prod + (M_neg2 <<< i);
                3'b101, 3'b110: Prod = Prod + (M_neg <<< i);
                default:        Prod = Prod + 16'd0;
            endcase
        end
    end
endmodule