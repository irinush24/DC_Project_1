module alu_top (
    input [7:0] A,
    input [7:0] B,
    input [3:0] ALU_Sel,
    output [7:0] Result,
    output Z, // Zero flag
    output N, // Negative flag
    output V  // Overflow flag
);

    // Interconnect wires
    wire [7:0] rca_out;
    wire rca_cout, rca_ovf;
    wire [7:0] b_mux; // B input for adder/subtractor
    wire sub_sel;
    
    wire [15:0] mul_out_16;
    wire [7:0] div_out;
    wire div_err;
    
    wire [7:0] and_out, or_out, xor_out;
    wire [7:0] lsl_out, lsr_out;
    
    // Control logic for Add/Sub
    assign sub_sel = (ALU_Sel == 4'b0001);
    assign b_mux = sub_sel ? ~B : B; // Two's complement inversion for SUB
    
    // Module Instantiations
    rca u_rca (
        .A(A),
        .B(b_mux),
        .cin(sub_sel), // +1 for two's complement if SUB
        .Sum(rca_out),
        .cout(rca_cout),
        .overflow(rca_ovf)
    );
    
    booth_r4 u_booth (
        .A(A),
        .B(B),
        .Prod(mul_out_16)
    );
    
    srt2 u_srt2 (
        .Dividend(A),
        .Divisor(B),
        .Quotient(div_out),
        .error_div0(div_err)
    );
    
    logic_unit u_logic (
        .A(A),
        .B(B),
        .Out_AND(and_out),
        .Out_OR(or_out),
        .Out_XOR(xor_out)
    );
    
    shifter u_shifter (
        .A(A),
        .shift_amt(B[2:0]),
        .Out_LSL(lsl_out),
        .Out_LSR(lsr_out)
    );
    
    mux_out u_mux (
        .sel(ALU_Sel),
        .in_add_sub(rca_out),
        .in_mul(mul_out_16[7:0]), // Truncate 16-bit product to 8-bit for ALU width
        .in_div(div_out),
        .in_and(and_out),
        .in_or(or_out),
        .in_xor(xor_out),
        .in_lsl(lsl_out),
        .in_lsr(lsr_out),
        .out(Result)
    );
    
    // Status Flags
    assign Z = (Result == 8'h00);
    assign N = Result[7];
    
    // Overflow logic depends on the active operation
    reg ovf_reg;
    always @(*) begin
        case(ALU_Sel)
            4'b0000, 4'b0001: ovf_reg = rca_ovf; // ADD / SUB
            4'b0010: begin // MUL: Overflow if upper 8 bits aren't sign extensions of lower 8 bits
                if ((mul_out_16[15:7] == 9'b000000000) || (mul_out_16[15:7] == 9'b111111111))
                    ovf_reg = 1'b0;
                else
                    ovf_reg = 1'b1;
            end
            4'b0011: begin // DIV: Overflow if division by zero, or -128 / -1
                if (div_err || (A == 8'h80 && B == 8'hFF))
                    ovf_reg = 1'b1;
                else
                    ovf_reg = 1'b0;
            end
            default: ovf_reg = 1'b0; // No overflow for logic/shift ops
        endcase
    end
    
    assign V = ovf_reg;

endmodule
`timescale 1ns / 1ps


module alu_top_tb;

    // Inputs
    reg [7:0] A;
    reg [7:0] B;
    reg [3:0] ALU_Sel;

    // Outputs
    wire [7:0] Result;
    wire Z, N, V;

    // Instantiate the ALU
    alu_top uut (
        .A(A), .B(B), .ALU_Sel(ALU_Sel), 
        .Result(Result), .Z(Z), .N(N), .V(V)
    );

    initial begin
        $display("\n=== STARTING ALU TESTS ===\n");

        // ---------------------------------------------------------
        // ADDITION (0000)
        // ---------------------------------------------------------
        ALU_Sel = 4'b0000; A = 15; B = 25; #10;
        $display("ADD: %0d + %0d = %0d \t\t(Flags -> Z:%b N:%b V:%b)", 
                 $signed(A), $signed(B), $signed(Result), Z, N, V);

        ALU_Sel = 4'b0000; A = 127; B = 1; #10;
        $display("ADD: %0d + %0d = %0d \t(Flags -> Z:%b N:%b V:%b) <- Overflow!", 
                 $signed(A), $signed(B), $signed(Result), Z, N, V);


        // ---------------------------------------------------------
        // SUBTRACTION (0001)
        // ---------------------------------------------------------
        $display(""); // Empty line for readability
        ALU_Sel = 4'b0001; A = 20; B = 5; #10;
        $display("SUB: %0d - %0d = %0d \t\t(Flags -> Z:%b N:%b V:%b)", 
                 $signed(A), $signed(B), $signed(Result), Z, N, V);

        ALU_Sel = 4'b0001; A = 5; B = 20; #10;
        $display("SUB: %0d - %0d = %0d \t\t(Flags -> Z:%b N:%b V:%b) <- Negative!", 
                 $signed(A), $signed(B), $signed(Result), Z, N, V);


        // ---------------------------------------------------------
        // MULTIPLICATION (0010)
        // ---------------------------------------------------------
        $display("");
        ALU_Sel = 4'b0010; A = 7; B = 6; #10;
        $display("MUL: %0d * %0d = %0d \t\t(Flags -> Z:%b N:%b V:%b)", 
                 $signed(A), $signed(B), $signed(Result), Z, N, V);

        ALU_Sel = 4'b0010; A = -8; B = 4; #10;
        $display("MUL: %0d * %0d = %0d \t\t(Flags -> Z:%b N:%b V:%b)", 
                 $signed(A), $signed(B), $signed(Result), Z, N, V);


        // ---------------------------------------------------------
        // DIVISION (0011)
        // ---------------------------------------------------------
        $display("");
        ALU_Sel = 4'b0011; A = 40; B = 8; #10;
        $display("DIV: %0d / %0d = %0d \t\t(Flags -> Z:%b N:%b V:%b)", 
                 $signed(A), $signed(B), $signed(Result), Z, N, V);

        ALU_Sel = 4'b0011; A = 25; B = 0; #10;
        $display("DIV: %0d / %0d = %0d \t\t(Flags -> Z:%b N:%b V:%b) <- Div by Zero Error!", 
                 $signed(A), $signed(B), $signed(Result), Z, N, V);


        // ---------------------------------------------------------
        // LOGIC OPERATIONS (Printed in Binary for clarity)
        // ---------------------------------------------------------
        $display("\n--- LOGIC & SHIFT (Shown in Binary) ---");
        
        ALU_Sel = 4'b0100; A = 8'b11110000; B = 8'b10101010; #10;
        $display("AND: %b & %b = %b", A, B, Result);

        ALU_Sel = 4'b0101; A = 8'b11110000; B = 8'b10101010; #10;
        $display("OR : %b | %b = %b", A, B, Result);

        ALU_Sel = 4'b0110; A = 8'b11110000; B = 8'b10101010; #10;
        $display("XOR: %b ^ %b = %b", A, B, Result);

        // ---------------------------------------------------------
        // SHIFT OPERATIONS (A in binary, B in decimal)
        // ---------------------------------------------------------
        ALU_Sel = 4'b0111; A = 8'b00001111; B = 2; #10;
        $display("LSL: %b << %0d = %b", A, B, Result);

        ALU_Sel = 4'b1000; A = 8'b11110000; B = 3; #10;
        $display("LSR: %b >> %0d = %b", A, B, Result);

        $display("\n=== TESTS COMPLETE ===\n");
    end

endmodule