module mux_out (
    input [3:0] sel,
    input [7:0] in_add_sub,
    input [7:0] in_mul,
    input [7:0] in_div,
    input [7:0] in_and,
    input [7:0] in_or,
    input [7:0] in_xor,
    input [7:0] in_lsl,
    input [7:0] in_lsr,
    output reg [7:0] out
);
    always @(*) begin
        case(sel)
            4'b0000: out = in_add_sub; // ADD
            4'b0001: out = in_add_sub; // SUB
            4'b0010: out = in_mul;     // MUL
            4'b0011: out = in_div;     // DIV
            4'b0100: out = in_and;     // AND
            4'b0101: out = in_or;      // OR
            4'b0110: out = in_xor;     // XOR
            4'b0111: out = in_lsl;     // LSL
            4'b1000: out = in_lsr;     // LSR
            default: out = 8'h00;
        endcase
    end
endmodule