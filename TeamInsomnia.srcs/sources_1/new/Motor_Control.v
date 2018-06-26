`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2018 11:04:01 PM
// Design Name: 
// Module Name: Motor_Control
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


module Motor_Control(
    input forward,
    input back,
    input left,
    input right,
    input clk,
    input [5:0]sw,
    input brake,
    output IN1,
    output IN2,
    output IN3,
    output IN4,
    output ENA,
    output ENB
    );
    
    assign ENB = ENA;
    
       reg FB_r, LR_r, S_r;
     
     //To be removed on favor of 2 bit register
     
     always @(*)
     begin
         if (forward)
         begin
             FB_r <= 1;
             S_r <= 1;
         end
        else if (left)
         begin
             LR_r <= 1;
             S_r <= 0;
         end
         else if (right)
         begin
             LR_r <= 0;
             S_r <= 0;
         end
         else if (back)
         begin
             FB_r <= 0;
             S_r <= 1;
         end
         else
         begin
            FB_r <= 1;
            S_r <= 1;
         end
     end
    
    PWM speed (
        .clk(clk),
        .brake(brake),
        .sw(sw),
        .enable(ENA)
        );
        
    Direction_Conversion Decode (
        .FB(FB_r),
        .LR(LR_r),
        .S(S_r),
        .brake(brake),
        .IN1(IN1),
        .IN2(IN2),
        .IN3(IN3),
        .IN4(IN4)
        );
        
endmodule
