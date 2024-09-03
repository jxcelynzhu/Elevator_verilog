/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_elevator_output (
  input  wire [7:0] ui_in,    // Dedicated inputs: User-selected floor
  output wire [7:0] uo_out,   // Dedicated outputs: Currently accessed floor
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);
 
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};
  
  //Output: 1
  wire or0_ouA, or0_ouB, or0_ouC, or0_ouD, or0_ouE;  // Output wire of OR gates
  
  assign or0_ouA = ui_in[1] + ui_in[2]; // OR gate connecting inputs 0 and 1
  assign or0_ouB = ui_in[4] + ui_in[5]; // OR gate connecting inputs 4 and 5
  assign or0_ouC = ui_in[6] + ui_in[7];
  assign or0_ouD = or0_ouA + or0_ouB;
  assign or0_ouE = or0_ouD + or0_ouC;
  assign uo_out[0] = or0_ouE;
  
  // Output 2
  wire or1_ouA, or1_ouB, or1_ouC, or1_ouD, or1_ouE;
  
  assign or1_ouA = ui_in[0] + ui_in[1];
  assign or1_ouB = ui_in[2] + ui_in[3];
  assign or1_ouC = ui_in[6] + ui_in[7];
  assign or1_ouD = or1_ouA + or1_ouB;
  assign or1_ouE = or1_ouC + or1_ouD;
  assign uo_out[1] = or1_ouE;


  // Output 3 
  wire or2_ouA, or2_ouB, or2_ouC, or2_ouD, or2_ouE, or2_ouF; 
  
  assign or2_ouA = ui_in[0] + ui_in[2];
  assign or2_ouB = ui_in[3] + ui_in[4];
  assign or2_ouC = ui_in[5] + ui_in[6];
  assign or2_ouE = or2_ouC + ui_in[7];
  assign or2_ouD = or2_ouA + or2_ouB;
  assign or2_ouF = or2_ouD + or2_ouE;
  assign uo_out[2] = or2_ouF;
	
  // Output 4
  wire or3_ouA, or3_ouB, or3_ouC, or3_ouD; 
  
  assign or3_ouA = ui_in[1] + ui_in[2];
  assign or3_ouB = ui_in[4] + ui_in[5];
  assign or3_ouC = or3_ouA + or3_ouB;
  assign or3_ouD = or3_ouC + ui_in[7];
  assign uo_out[3] = or3_ouD;
  
  // Output 5
  wire or4_ouA, or4_ouB; 
  
  assign or4_ouA = ui_in[1] + ui_in[5];
  assign or4_ouB = or4_ouA + ui_in[7];
  assign uo_out[4] = or4_ouB;
  
  // Output 6
  wire or5_ouA, or5_ouB, or5_ouC; 
  
  assign or5_ouA = ui_in[3] + ui_in[4];
  assign or5_ouB = ui_in[5] + ui_in[7];
  assign or5_ouC = or5_ouA + or5_ouB;
  assign uo_out[5] = or5_ouC;
  
  // Output 7
  wire or6_ouA, or6_ouB, or6_ouC, or6_ouD, or6_ouE; 
  
  assign or6_ouA = ui_in[1] + ui_in[2];
  assign or6_ouB = ui_in[3] + ui_in[4];
  assign or6_ouC = ui_in[5] + ui_in[7];
  assign or6_ouD = or6_ouA + or6_ouB;
  assign or6_ouE = or6_ouC + or6_ouD;
  assign uo_out[6] = or6_ouE;
	
  assign uo_out[7] = 0;
  
  wire[7:0] elevator_cf;
  
  // Setting inactive output paths
  assign uio_out = 8'b00000000;
  assign uio_oe = 8'b00000000;
  
  // Instantiating clock components to elevator design
  elevator_design inst (
    .clk(clk),
    .floor(uo_out),
    .y(elevator_cf)
  );
   
  
endmodule

module elevator_design(input clk, input [7:0] floor, output reg [7:0] y);
  
  reg [7:0] cf = 8'b0001; // Current floor initialized to 1
  reg [31:0] clkdiv = 32'd0;
  
  always @(posedge clk) begin
    clkdiv <= clkdiv + 1; 
  end
  
  // Modified = to <= to use a non-blocking assignment
  
  always @(posedge clkdiv[24]) begin
    if (floor < cf) begin // Current floor is lower than desired floor
      if (cf != 8'b0001) 
        cf <= cf >> 1; // Shift current floor right by one bit, descending by 1 floor
    end else if (floor > cf) begin // Current floor is higher than desired floor
      if (cf != 8'b0001)
        cf <= cf << 1; // Shift current floor left by one bit, ascending by 1 floor
    end else if (floor == cf) begin // Current floor is the same floor as desired floor
      cf <= floor; // Stay on current floor
    end
  end
              
  assign y = cf;
              
endmodule


// Wait state
/*
module wait ();

endmodule
*/

// Ready state
/*
module ready();
  
endmodule
*/

