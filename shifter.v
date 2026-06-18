module shifter (
    input [7:0] A,
    input [2:0] shift_amt, // Using lower 3 bits of B as shift amount
    output [7:0] Out_LSL,
    output [7:0] Out_LSR
);
    assign Out_LSL = A << shift_amt;
    assign Out_LSR = A >> shift_amt;
endmodule