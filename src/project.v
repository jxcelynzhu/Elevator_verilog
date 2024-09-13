/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module elevator_state_machine (
  input clk, // Clock signal
  input reset, // Reset signal -- ?
  
  input wire [3:0] requested_floor, // -- ? or reg
  input wire [3:0] current_floor 
  
  /*input some_input,
  output reg some_output*/
);

  // Define the states
  parameter IDLE = 2'b00;
  //parameter NEW_REQUEST = 2'b01;
  parameter MOVING_UP = 2'b10;
  parameter MOVING_DOWN = 2'b11;

  // State register
  reg [1:0] current_state, next_state;

  // Combinational logic for next state and output
  always @(*) begin
    case (current_state)
      IDLE: begin
        //some_output = 0;
        if (requested_floor > current_floor) 
          next_state = MOVING_UP;
        else if (requested_floor < current_floor) 
          next_state = MOVING_DOWN;
        else 
          next_state = IDLE;
      end
      MOVING_UP: begin
        //some_output = 1;  // Perform some work
        if (requested_floor == current_floor)  // Check for completion
          next_state = IDLE;
        else
          next_state = MOVING_UP;
      end
      MOVING_DOWN: begin
        //some_output = 0;
        if (requested_floor == current_floor)  // Reset condition
          next_state = IDLE;
        else
          next_state = MOVING_DOWN;
      end
      default:
        next_state = IDLE; // Error state, go back to IDLE
    endcase
  end

  // Sequential logic for state register
  always @(posedge clk or posedge reset) begin
    if (reset)
      current_state <= IDLE;
    else
      current_state <= next_state;
  end

endmodule

// 7-segment display
module segment7(
  input wire [3:0] floor, // 4 bit input to display digits < 10
  output reg [6:0] segment // 7 bit output for 7-segment display
);
  
  always @(*) begin
    case (floor)
      0: segment = 7'b0000001;
      1: segment = 7'b1001111;
      2: segment = 7'b0010010;
      3: segment = 7'b0000110;
      4: segment = 7'b1001100;
      5: segment = 7'b0100100;
      6: segment = 7'b0100000;
      7: segment = 7'b0001111;
      8: segment = 7'b0000000;
      9 : segment = 7'b0000100;
      default: seg = 7'b1111111; // All segments turned off
    endcase
  end
endmodule
