`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2018 12:46:03 PM
// Design Name: 
// Module Name: Beacon_Module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Beacon_Module(
    input clk,
    input micLeft,
    input micRight,
    output[2:0] direction
    );

reg micRight_reg;  
reg micLeft_reg;
reg direction_reg;
reg direction_regms;
reg [2:0]MotorDirection_r;

always @(posedge micLeft)       // We save the value of micRight at every posedge of micLeft
    begin
    micRight_reg <= micRight;
    end

always @(posedge clk)           // Every time the clk rises, we set direction to the value of micRight at the rising edge of
                                // micLeft. We do this because if micRight = 1 at the rising edge of micLeft, this means micRight
                                // was already 1 and heard the signal first. If micRight = 0 at the rising edge of micLeft, this
                                // means micRight hasn't been heard even though micLeft is. This shows micLeft hears the signal first.
    begin
    direction_reg <= micRight_reg;      // If micRight is heard first, set direction = 1. if micLeft is heard first, set direction=0.
    end

always @(posedge clk)                   // Repeat to maintain metastability.
    begin
    direction_regms <= direction_reg;
    end
    
always @(posedge clk)
    begin
     if (direction_regms) begin
     MotorDirection_r <= 3'b010;
     end else if (direction_regms) begin
     MotorDirection_r <= 3'b110;
     end else begin
     MotorDirection_r <= 3'b000;
     end
    end
     
assign direction = MotorDirection_r;       // direction =0 means go left. direction =1 means go right.

endmodule

