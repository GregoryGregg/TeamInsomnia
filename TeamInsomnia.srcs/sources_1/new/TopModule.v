`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2018 01:13:31 PM
// Design Name: 
// Module Name: TopModule
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


module TopModule(
    input clk,
    input [5:0]sw,
    input forward,
    input back,
    input left,
    input right,
    input brake,
    output IN1,
    output IN2,
    output IN3,
    output IN4,
    output ENA,
    output ENB
    );
    
    reg FB_r, LR_r, S_r;
    
    always @(*)
    begin
        if (forward)
        begin
            FB_r <= 1;
            S_r <= 1;
        end
        if (left)
        begin
            LR_r <= 1;
            S_r <= 0;
        end
        if (right)
        begin
            LR_r <= 0;
            S_r <= 0;
        end
        if (back)
        begin
            FB_r <= 0;
            S_r <= 1;
        end
    end
    
    Motor_Control MotorSurface(
        .FB(FB_r),
        .LR(LR_r),
        .S(S_r),
        .clk(clk),
        .sw(sw),
        .brake(~brake),
        .IN1(IN1),
        .IN2(IN2),
        .IN3(IN3),
        .IN4(IN4),
        .ENA(ENA),
        .ENB(ENB)
        );
        
endmodule
