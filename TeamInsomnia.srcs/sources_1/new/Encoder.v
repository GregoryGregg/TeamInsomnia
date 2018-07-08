`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2018 01:33:54 AM
// Design Name: 
// Module Name: Encoder
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


module Encoder(
 input clk,
 input [2:0]direction,
 input [5:0]sw,
 output SWA,
 output SWB
    );
    
    reg [5:0] SWB_r;
    
    assign SWB = SWB_r;
    assign SWA = sw;
    
    
endmodule
