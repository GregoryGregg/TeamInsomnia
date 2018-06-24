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
    input direction,
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
    
    PWM speed (
        .clk(clk),
        .brake(brake),
        .sw(sw),
        .enable(ENA)
        );
        
    Direction_Conversion Decode (
        .direction(direction),
        .brake(brake),
        .IN1(IN1),
        .IN2(IN2),
        .IN3(IN3),
        .IN4(IN4)
        );
        
endmodule
