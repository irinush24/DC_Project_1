// full_adder.v
module full_adder(
    input a, b, cin,
    output sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule

// rca.v
module rca (
    input [7:0] A,
    input [7:0] B,
    input cin,
    output [7:0] Sum,
    output cout,
    output overflow
);
    wire [7:0] c;
    
    full_adder fa0 (A[0], B[0], cin,  Sum[0], c[0]);
    full_adder fa1 (A[1], B[1], c[0], Sum[1], c[1]);
    full_adder fa2 (A[2], B[2], c[1], Sum[2], c[2]);
    full_adder fa3 (A[3], B[3], c[2], Sum[3], c[3]);
    full_adder fa4 (A[4], B[4], c[3], Sum[4], c[4]);
    full_adder fa5 (A[5], B[5], c[4], Sum[5], c[5]);
    full_adder fa6 (A[6], B[6], c[5], Sum[6], c[6]);
    full_adder fa7 (A[7], B[7], c[6], Sum[7], c[7]);

    assign cout = c[7];
    // Overflow occurs if the carry into the MSB doesn't match the carry out of the MSB
    assign overflow = c[6] ^ c[7];
endmodule