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
 input brake,
 input ea,
 input eb,
 input [2:0]direction,
 input [5:0]sw,
 output [5:0]swa,
 output [5:0]swb
    );
    
    reg [3:0] tolerance = 4'b1111;
    reg check_a, check_b;
    reg [14:0] countb_r, counta_r;
    reg [5:0] swb_r;
    reg [26:0] division;
    
    assign swb = swb_r;
    assign swa = sw;
    
    always @(eb)
    begin
        if (~brake)
        begin
            countb_r <= countb_r + 1'b1;
        end
    end
    
    always @(ea)
    begin
        if (~brake)
        begin
            counta_r <= counta_r + 1'b1;
        end
    end
    
    always @(*)
    begin
        if ((counta_r - countb_r) > tolerance)
        begin
            swb_r <= swb_r + 1;
        end else if ((counta_r - countb_r) < tolerance)
        begin
            swb_r <= swb_r - 1;
        end else
        begin
            swb_r <= sw;
        end
    end
            
endmodule
