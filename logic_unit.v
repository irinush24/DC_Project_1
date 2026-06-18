module logic_unit (
    input [7:0] A,
    input [7:0] B,
    output [7:0] Out_AND,
    output [7:0] Out_OR,
    output [7:0] Out_XOR
);
    assign Out_AND = A & B;
    assign Out_OR  = A | B;
    assign Out_XOR = A ^ B;
endmodule