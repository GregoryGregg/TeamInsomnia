`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2018 11:06:48 PM
// Design Name: 
// Module Name: PWM
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


module PWM(
input clk,
input [14:0]ratio,
input brake,
input coast,
input [5:0]sw,
output enable
    );
    
    reg pwm;
    reg [14:0] cntr = 0;
    
    assign enable = pwm;
    
    always @(posedge clk)
    begin
        if (brake)
            pwm <= 1'b1;
        else if (coast)
            pwm <= 1'b0;
        else
        begin
            if (ratio*sw > cntr)
                pwm <= 1'b1;
            else
                pwm <= 1'b0;
        end
        cntr <= cntr + 1;
    end
endmodule
