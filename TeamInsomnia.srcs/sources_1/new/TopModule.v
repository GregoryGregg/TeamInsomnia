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
    
    reg[1:0] direction_r;
    
    initial
        direction_r = 2'b00;
    
    always @(*)
    begin
        if (forward)
            direction_r <= 2'b00;
        if (left)
            direction_r <= 2'b10;
        if (right)
            direction_r <= 2'b01;
        if (back)
            direction_r <= 2'b00;
    end
    
    Motor_Control MotorSurface(
        .direction(direction_r),
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
