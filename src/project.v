/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none 

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out [7] = 0;  
  assign uio_out = 0;
  assign uio_oe  = 0;
 
  wire [3:0] floor;
 
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};
  elevator_state_machine em (
    .clk(clk),
    .reset(rst_n),
    //.requested_floor(ui_in[3:0]),
    .requested_floor(4'd2),
    .current_floor(floor)     //.IDLE (uo_out [7])
  );
  
  segment7 s7 (
    .floor(floor),
    .segment(uo_out[6:0])
  );
endmodule


module elevator_state_machine (
  input clk, // Clock signal
  input reset, // Reset signal 
  input wire [3:0] requested_floor,
  output reg [3:0] current_floor
    //output reg IDLE
);

  // Define the states
  parameter IDLE = 2'b00;
  parameter MOVING_UP = 2'b10;
  parameter MOVING_DOWN = 2'b11;
  parameter DELAY_COUNT = 32'd10000000;  // make longer for real hardware

  // State register
  reg [1:0] current_state, next_state;
  reg [31:0] delay;

  // Combinational logic for next state and output
  always @(*) begin
    case (current_state)
      IDLE: begin
       // IDLE = 1
        if (current_floor < requested_floor)
          next_state = MOVING_UP;
        else if (current_floor > requested_floor)
          next_state = MOVING_DOWN;
        else
          next_state = IDLE;
      end
      MOVING_UP: begin
       // IDLE = 0
        if (current_floor == requested_floor)
          next_state = IDLE;
         else 
           next_state = MOVING_UP;
        /*if (current_floor < requested_floor)  
          next_state = MOVING_UP;
        else
          next_state = IDLE; // Check for completion*/
      end
      MOVING_DOWN: begin
        /*if (current_floor > requested_floor)  
      	  next_state = MOVING_DOWN;
        else
          next_state = IDLE; // Reset condition*/
        // IDLE = 0
        if (current_floor == requested_floor)
          next_state = IDLE;
         else 
           next_state = MOVING_DOWN;
      end
      default:
        next_state = IDLE; // Error state, go back to IDLE
    endcase
  end
    
  
  // Sequential logic 
  always @(posedge clk or posedge reset) begin
    if (reset) begin
          current_state <= IDLE;
          current_floor <= 0;
          delay <= 0;
    end else begin
      current_state <= next_state; //Update the current state
      //Update the current_floor
      
      if (delay == DELAY_COUNT) begin
        delay <= 0; //Reset delay
        if (current_state == MOVING_UP) 
          current_floor <= current_floor + 1;
        else if (current_state == MOVING_DOWN) 
             current_floor <= current_floor - 1;
      end else 
         delay <= delay + 1;
      
    end
  end
endmodule


// 7-segment display

module segment7(
  input wire [3:0] floor, // 4 bit input to display digits < 10
  output reg [6:0] segment // 7 bit output for 7-segment display
);
 
  always @(*) begin
    case (floor)
      0: segment = 7'b1000000;
      1: segment = 7'b1111001;
      2: segment = 7'b0100100;
      3: segment = 7'b0110000;
      4: segment = 7'b0011001;
      5: segment = 7'b0010010;
      6: segment = 7'b0000010;
      7: segment = 7'b1111000;
      8: segment = 7'b0000000;
      9: segment = 7'b0010000;
      default: segment = 7'b1111111;
      /*
      0: segment = 7'b0000001; 1000000
      1: segment = 7'b1001111; 1111001
      2: segment = 7'b0010010; 0100100
      3: segment = 7'b0000110; 0110000
      4: segment = 7'b1001100; 0011001
      5: segment = 7'b0100100; 0010010
      6: segment = 7'b0100000; 0000010
      7: segment = 7'b0001111;
      8: segment = 7'b0000000;
      9 : segment = 7'b0000100;
      default: segment = 7'b1111111; // All segments turned off*/
    endcase
  end
endmodule
