module logic_unit #(parameter w = 8)
(
    input [w-1:0] a, b,
    input [1:0] op,           // op: 0 = and, 1 = or, 2 = xor
    output reg [w-1:0] c
);

always @(*)
begin 
    case (op)
        2'b00: c = a & b;
        2'b01: c = a | b;
        2'b10: c = a ^ b;
        default: c = {w{1'bz}};      // All bits are set to High-Z to signify the unidentified operation
    endcase
end
endmodule

/*module logic_unit_tb();
    reg [7:0] a, b;
    reg [1:0] op;
    wire [7:0] res;

    logic_unit #(.w(8)) dut(.a(a), .b(b), .op(op), .c(res));

    initial begin
        $display("Time\t op\t    a\t      b\t       res");
        $display("----------------------------------------------------------------");

        // --- Test 1: Bitwise AND (op = 00) ---
        a = 8'b10101010; b = 8'b11110000; op = 2'b00;
        #10;
        $display("%0t\t AND \t %b \t %b \t %b", $time, a, b, res);

        // --- Test 2: Bitwise OR (op = 01) ---
        a = 8'b10101010; b = 8'b11110000; op = 2'b01;
        #10;
        $display("%0t\t OR  \t %b \t %b \t %b", $time, a, b, res);

        // --- Test 3: Bitwise XOR (op = 10) ---
        a = 8'b10101010; b = 8'b11110000; op = 2'b10;
        #10;
        $display("%0t\t XOR \t %b \t %b \t %b", $time, a, b, res);

        // --- Test 4: Default Case / High-Z (op = 11) ---
        op = 2'b11;
        #10;
        $display("%0t\t DEF \t %b \t %b \t %b (High-Z Expected)", $time, a, b, res);
    end
endmodule*/