module booth_radix4 (
    input  wire              clk,
    input  wire              enable,
    input  wire              rst_n,
    input  wire signed [7:0] inbus,
    output wire              done,
    output wire [7:0]        outbus
);

    // Control signals (Wires because they connect modules)
    wire [9:0] c; 
    wire       stop;
    tri  [7:0] output_buffer;

    // Internal connections
    wire signed [8:0] A_reg, M_reg, Q_reg;
    wire [8:0] adder_o;
    wire [8:0] M_shifted;
    wire [1:0] counter_o;
    wire       count_done;

    // --- Control Unit ---
    cu_booth_radix4 ctrl_unit (
        .clk(clk),
        .start(enable),
        .rst_n(rst_n),
        .count_done(count_done),
        .q_window(Q_reg[2:0]), 
        .stop(stop),
        .c(c)
    );

    assign done = stop;

    // --- Data Path (Using standard modules) ---
    // A Register
    register #(.WIDTH(9)) reg_A (
        .clk(clk), .rst_n(rst_n),
        .load_en(c[2]), .shift_en(c[4]),
        .sr(A_reg[8]), .sl(1'b0), .shift_dir(c[4]),
        .d(adder_o), .q(A_reg)
    );

    // Q Register
    register #(.WIDTH(9)) reg_Q (
        .clk(clk), .rst_n(rst_n),
        .load_en(c[1]), .shift_en(c[4]),
        .sr(A_reg[1]), .sl(1'b0), .shift_dir(c[4]),
        .d({inbus, 1'b0}), .q(Q_reg)
    );

    // M Register
    register #(.WIDTH(9)) reg_M (
        .clk(clk), .rst_n(rst_n),
        .load_en(c[0]), .shift_en(1'b0),
        .d({inbus[7], inbus}), .q(M_reg)
    );

    assign M_shifted = (c[3]) ? (M_reg << 1) : M_reg;

    rca #(.WIDTH(9)) adder_inst (
        .cin(c[8]),
        .a(A_reg),
        .b(c[9] ? ~M_shifted : M_shifted),
        .sum(adder_o)
    );

    tristate_buffer_bus #(.WIDTH(8)) res_out (
        .data_in(Q_reg[8:1]),
        .enable(c[7]),
        .data_out(output_buffer)
    );

    assign outbus = output_buffer;

endmodule

module tb_booth_radix4();

    // 1. Declare Testbench Signals
    // Inputs to the module must be 'reg' because we drive them inside an 'initial' block
    reg clk;
    reg enable;
    reg rst_n;
    reg signed [7:0] inbus;

    // Outputs from the module must be 'wire'
    wire done;
    wire [7:0] outbus;

    // 2. Instantiate the Device Under Test (DUT)
    booth_radix4 dut (
        .clk(clk),
        .enable(enable),
        .rst_n(rst_n),
        .inbus(inbus),
        .done(done),
        .outbus(outbus)
    );

    // 3. Clock Generation (10ns period -> 100MHz clock)
    initial clk = 0;
    always #5 clk = ~clk;

    // 4. Test Sequence
    initial begin
        // --- Initialization ---
        rst_n = 0;
        enable = 0;
        inbus = 8'd0;

        // Release reset after 20ns
        #20 rst_n = 1;
        #10; 

        $display("==================================================");
        $display("   Starting Radix-4 Booth Multiplier Testbench    ");
        $display("==================================================");

        // --- Test Case 1: Positive x Positive ---
        // Step 1: Put Multiplicand (M) on the bus
        inbus = 8'd6; 
        #10; // Wait 1 clock cycle for the Control Unit to see it
        
        // Step 2: Put Multiplier (Q) on the bus and pulse enable
        inbus = 8'd3; 
        enable = 1;
        #10; // Hold enable for 1 clock cycle
        enable = 0;

        // Step 3: Wait for the module to finish computing
        wait(done);
        #1; // Tiny delay to let the output buffer stabilize
        $display("TC1 ( 6 *  3): Expected =   18, Actual = %4d", $signed(outbus));
        #20; // Gap before the next test


        // --- Test Case 2: Positive x Negative ---
        inbus = 8'd7; 
        #10;
        inbus = -8'd4; 
        enable = 1;
        #10;
        enable = 0;
        
        wait(done);
        #1;
        $display("TC2 ( 7 * -4): Expected =  -28, Actual = %4d", $signed(outbus));
        #20;


        // --- Test Case 3: Negative x Negative ---
        inbus = -8'd5; 
        #10;
        inbus = -8'd2; 
        enable = 1;
        #10;
        enable = 0;
        
        wait(done);
        #1;
        $display("TC3 (-5 * -2): Expected =   10, Actual = %4d", $signed(outbus));
        #20;


        // --- Test Case 4: Multiply by Zero ---
        inbus = -8'd12; 
        #10;
        inbus = 8'd0; 
        enable = 1;
        #10;
        enable = 0;
        
        wait(done);
        #1;
        $display("TC4 (-12*  0): Expected =    0, Actual = %4d", $signed(outbus));
        #20;

        $display("==================================================");
        $display("                  Tests Finished                  ");
        $display("==================================================");
        
        $finish; // Stop the simulation
    end

endmodule