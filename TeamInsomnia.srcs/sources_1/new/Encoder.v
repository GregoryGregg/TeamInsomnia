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
 output [5:0]swb
    );
    
    reg [3:0] tolerance = 4'b1111;
    reg check_a = 1'b0; 
    reg check_b = 1'b0;
    reg check;
    reg [14:0] countb_r, counta_r;
    reg [5:0] swb_r;
    reg [27:0] counter_frequency;
    reg [27:0] limit = 27'd67108864;
    
    assign swb = swb_r;
    
    always @(posedge clk)
    begin
        if (counter_frequency == limit)
        begin
            counter_frequency <= 0;
            check <= ~check;
        end
        counter_frequency <= counter_frequency + 1'b1;
    end
    
    always @(posedge check)
    begin
        if (~brake)
        begin
            if (ea && ~check_a)
            begin
                check_a <= 1'b1;
                counta_r <= counta_r + 1'b1;
            end else if (~ea && check_a)
            begin
                check_a <= 1'b0;
            end
        end if (~brake)
        begin
            if (eb && ~check_b)
            begin
                check_b <= 1'b1;
                countb_r <= countb_r + 1'b1;
            end else if (~eb && check_b)
            begin
                check_b <= 1'b0;
            end
        end
   end
    
    always @(posedge clk)
    begin
        if ((counta_r - countb_r) > tolerance)
        begin
            swb_r <= swb_r + 1;
        end else if ((counta_r - countb_r) < tolerance)
        begin
            swb_r <= swb_r - 1;
        end
    end
            
endmodule
