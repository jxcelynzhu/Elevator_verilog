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
      
  // Setting inactive output paths
  assign uio_out = 8'b00000000;
  assign uio_oe = 8'b00000000;
  
  // Instantiating clock components to elevator design
  elevator_design inst (
    .clk(clk),
    .floor(ui_in), //User input to elevator_design 
    .uo_out(uo_out) //Output based on the current floor
  );
endmodule

module elevator_design(input wire clk, input wire [7:0] floor, output wire [7:0] uo_out);  
  reg [7:0] cf = 8'b0001; // Current floor initialized to 1
  reg [31:0] clkdiv = 32'd0;
  
  // Slowing down clock during transitions
  always @(posedge clk) begin
    clkdiv <= clkdiv + 1; 
  end
  
  // Modified = to <= to use a non-blocking assignment
    
  always @(posedge clkdiv[24]) begin
    if (floor < cf) begin // Current floor is lower than desired floor
      if (cf != 8'b0001) begin
        cf <= cf >> 1; // Shift current floor right by one bit, descending by 1 floor
        //assign uo_out[0]= or0_ouE;
      end
    end else if (floor > cf) begin // Current floor is higher than desired floor
      if (cf != 8'b0001) begin
        cf <= cf << 1; // Shift current floor left by one bit, ascending by 1 floor
      end
    end else if (floor == cf) begin // Current floor is the same floor as desired floor
      cf <= floor; // Stay on current floor
      check_floor(cf, floor, uo_out);
    end
  end              
endmodule

module check_floor (
  input wire [7:0] cf, 
  input wire[7:0] floor, 
  output wire[7:0] uo_out
  );
 
  if (cf == 8'b00000001) begin
    //Output: 1
    wire or0_ouA, or0_ouB, or0_ouC, or0_ouD, or0_ouE;  // Output wire of OR gates

    assign or0_ouA = ui_in[1] + ui_in[2]; // OR gate connecting inputs 0 and 1
    assign or0_ouB = ui_in[4] + ui_in[5]; // OR gate connecting inputs 4 and 5
    assign or0_ouC = ui_in[6] + ui_in[7];
    assign or0_ouD = or0_ouA + or0_ouB;
    assign or0_ouE = or0_ouD + or0_ouC;
    assign uo_out[0] = or0_ouE;
  end 
  else if (cf == 8'b00000010) begin
    // Output 2
    wire or1_ouA, or1_ouB, or1_ouC, or1_ouD, or1_ouE;

    assign or1_ouA = ui_in[0] + ui_in[1];
    assign or1_ouB = ui_in[2] + ui_in[3];
    assign or1_ouC = ui_in[6] + ui_in[7];
    assign or1_ouD = or1_ouA + or1_ouB;
    assign or1_ouE = or1_ouC + or1_ouD;
    assign uo_out[1] = or1_ouE;
  end
  else if (cf == 8'b00000011) begin
    // Output 3 
    wire or2_ouA, or2_ouB, or2_ouC, or2_ouD, or2_ouE, or2_ouF; 

    assign or2_ouA = ui_in[0] + ui_in[2];
    assign or2_ouB = ui_in[3] + ui_in[4];
    assign or2_ouC = ui_in[5] + ui_in[6];
    assign or2_ouE = or2_ouC + ui_in[7];
    assign or2_ouD = or2_ouA + or2_ouB;
    assign or2_ouF = or2_ouD + or2_ouE;
    assign uo_out[2] = or2_ouF;
  end
  else if (cf == 8'b00000100) begin
    // Output 4
    wire or3_ouA, or3_ouB, or3_ouC, or3_ouD; 

    assign or3_ouA = ui_in[1] + ui_in[2];
    assign or3_ouB = ui_in[4] + ui_in[5];
    assign or3_ouC = or3_ouA + or3_ouB;
    assign or3_ouD = or3_ouC + ui_in[7];
    assign uo_out[3] = or3_ouD;
  end 
  else if (cf == 8'b00000101) begin
    // Output 5
    wire or4_ouA, or4_ouB; 

    assign or4_ouA = ui_in[1] + ui_in[5];
    assign or4_ouB = or4_ouA + ui_in[7];
    assign uo_out[4] = or4_ouB;
  end
  else if (cf == 8'b00000110) begin
    // Output 6
    wire or5_ouA, or5_ouB, or5_ouC; 

    assign or5_ouA = ui_in[3] + ui_in[4];
    assign or5_ouB = ui_in[5] + ui_in[7];
    assign or5_ouC = or5_ouA + or5_ouB;
    assign uo_out[5] = or5_ouC;
  end
  else if (cf == 8'b00000111) begin
    // Output 7
    wire or6_ouA, or6_ouB, or6_ouC, or6_ouD, or6_ouE; 

    assign or6_ouA = ui_in[1] + ui_in[2];
    assign or6_ouB = ui_in[3] + ui_in[4];
    assign or6_ouC = ui_in[5] + ui_in[7];
    assign or6_ouD = or6_ouA + or6_ouB;
    assign or6_ouE = or6_ouC + or6_ouD;
    assign uo_out[6] = or6_ouE;
  end 
  else 
    assign uo_out[7] = 0;
endmodule

