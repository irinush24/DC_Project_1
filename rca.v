module fac
(
    input x, y, ci,
    output z, co
);

    assign z = x ^ y ^ ci;
    assign co = (x & y) | (x & ci) | (ci & y);
endmodule

module rca_sub #(parameter w = 8)
(
    input [w-1:0] a, b,
    input en, op,       // op: 0 = add, 1 = subtract
    output [w-1:0] sum,
    output co
);
    wire [w-1:0] b_mux, c, s;

    // If op is 1, b must be complemented for subtraction, otherwise it stays the same
    assign b_mux = b ^ {w{op}};

    // The first carry in is now equivalent to the op because we must add 1 for 2's complement
    fac f0(.x(a[0]), .y(b_mux[0]), .z(s[0]), .co(c[0]), .ci(op));

    generate
        genvar i;
        for(i = 1; i < w; i = i + 1) begin: rca_generate
            fac fi(.x(a[i]), .y(b_mux[i]), .ci(c[i-1]), .z(s[i]), .co(c[i]));
        end 
    endgenerate

    assign sum = s;
    assign co = c[w-1];
    
endmodule

/*module rca_tb;
    reg [7:0] a, b;
    reg en = 1'b1, op;
    wire [7:0] sum;
    wire co;

    rca_sub #(.w(8)) dut(.a(a), .b(b), .op(op), .en(en), .sum(sum), .co(co));

    initial begin
        // --- Test 1: Simple Addition (5 + 3) ---
        op = 0; a = 8'd5; b = 8'd3;
        #10;
        $display("ADD: %d + %d = %d (Carry: %b)", a, b, sum, co);

        // --- Test 2: Addition with Carry (255 + 1) ---
        op = 0; a = 8'd255; b = 8'd1;
        #10;
        $display("ADD: %d + %d = %d (Carry: %b)", a, b, sum, co);

        // --- Test 3: Simple Subtraction (10 - 4) ---
        op = 1; a = 8'd10; b = 8'd4;
        #10;
        $display("SUB: %d - %d = %d (Carry/Borrow: %b)", a, b, sum, co);

        // --- Test 4: Subtraction resulting in negative (5 - 10) ---
        // Result will be in 2's complement (251)
        op = 1; a = 8'd5; b = 8'd10;
        #10;
        $display("SUB: %d - %d = %d (signed: %d)", a, b, sum, $signed(sum));
    end
endmodule*/