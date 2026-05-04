module register #(parameter WIDTH = 8)
   (
    input  wire              clk,
    input  wire              rst_n,
    input  wire              load_en,
    input  wire              shift_en,
    input  wire              sr,
    input  wire              sl,
    input  wire              shift_dir, // 0 = left shift, 1 = right shift
    input  wire [WIDTH-1:0]  d,
    output wire [WIDTH-1:0]  q
    );

   wire [WIDTH-1:0] shift_mux_out;
   wire [WIDTH-1:0] load_mux_out;
   
   wire             left_shift_wire;
   wire             right_shift_wire;

   // Combinational logic using assign
   assign left_shift_wire = ~shift_dir;
   assign right_shift_wire = shift_dir;
   
   // Loop to generate structural hardware for each bit
   genvar i;
   generate
      for (i = 0; i < WIDTH; i = i + 1) begin : gen_reg
         
         // Internal wires for the bit-level logic
         wire shift_src_left;
         wire shift_src_right;
         wire right_wire;
         wire left_wire;
         wire shift_src;

         // Determine where the shift data comes from based on position
         assign shift_src_left = (i == 0) ? sl : q[i - 1];
         assign shift_src_right = (i == WIDTH - 1) ? sr : q[i+1];

         // Structural Gate Instantiations
         and2_gate and_right (
                              .a(shift_src_right),
                              .b(right_shift_wire),
                              .y(right_wire)
                              );

         and2_gate and_left (
                             .a(shift_src_left),
                             .b(left_shift_wire),
                             .y(left_wire)
                             );
         
         or2_gate or_shift (
                            .a(right_wire),
                            .b(left_wire),
                            .y(shift_src)
                            );
         
         // Multiplexers to choose between Keeping Value, Shifting, or Loading[cite: 2]
         mux2 #(1) mux_shift(
			     .d0(q[i]),
			     .d1(shift_src),
			     .s(shift_en),
			     .y(shift_mux_out[i]));
         
	      mux2 #(1) mux_load (
			     .d0(shift_mux_out[i]),
			     .d1(d[i]),
			     .s(load_en),
			     .y(load_mux_out[i]));

         // The actual storage element (Flip-Flop)
         dff ff_inst (
                      .clk(clk),
                      .rst_n(rst_n),
                      .d(load_mux_out[i]),
                      .q(q[i])
		      );
      end
   endgenerate

endmodule