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
    input [2:0]Direction,
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

    reg [14:0] ratioA_r, ratioB_r;

    reg ratioA_r = (Direction == 110||101) ? (32768/(2*63)):(32768/63);
    reg ratioB_r = (Direction == 001||010) ? (32768/(2*63)):(32768/63);

    PWM speedB (
        .clk(clk),
        .brake(brake),
        .sw(sw,
        .enable(ENB)
    );
    
    PWM speedA (
        .clk(clk),
        .brake(brake),
        .sw(sw),
        .enable(ENA)
    );
        
    Direction_Conversion Decode (
        .Direction(Direction),
        .brake(brake),
        .IN1(IN1),
        .IN2(IN2),
        .IN3(IN3),
        .IN4(IN4)
    );
        
endmodule
