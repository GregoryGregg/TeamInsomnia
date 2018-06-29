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
    input [2:0]direction,
    input brake,
    output IN1,
    output IN2,
    output IN3,
    output IN4,
    output ENA,
    output ENB
    );
    
    Motor_Control MotorSurface(
        .Direction(direction),
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
