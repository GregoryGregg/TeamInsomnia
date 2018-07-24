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
 input coast,
 input [8:0]Adjust,
 input ea,
 input eb,
 input [2:0]direction,
 input [5:0]sw,
 output [5:0]swb
    );
    
    reg reset;
    reg [6:0] ERROR;
    reg [8:0] ADJUST;
    reg check_a; 
    reg check_b;
    reg check;
    reg [5:0] countb_r, counta_r;
    reg [5:0] swb_r;
    reg [30:0] counter_frequency = 1'b0;
    reg [30:0] limit = 30'd100000;
    
    
    assign swb = swb_r[5:0];
    
    always @(posedge clk)
    begin
        if (counter_frequency > limit)
        begin
            counter_frequency <= 0;
            check <= ~check;
        end
    counter_frequency <= counter_frequency + 1'b1;
    end
    
    always @(posedge clk)
    begin
        if (~brake && ~coast)
        begin
            if (ea && !check_a)
            begin
                check_a = 1'b1;
                counta_r <= counta_r + 1'b1;
            end if (!ea && check_a)
            begin
                check_a = 1'b0;
            end if (eb && !check_b)
            begin
                check_b = 1'b1;
                countb_r <= countb_r + 1'b1;
            end if (!eb && check_b)
            begin
                check_b = 1'b0;
            end
        end
    end
    
    always @(posedge check)
    begin
        ERROR = counta_r - countb_r;
        if (ERROR[6]) begin
        swb_r <= swb_r - ERROR[5:0]/Adjust;
        end else if (!ERROR[6]) begin
        swb_r <= swb_r + ERROR[5:0]/Adjust;
        end
    end
            
endmodule
