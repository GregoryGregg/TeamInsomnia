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
//    input signed [8:0]Adjust,
    input brake,
    input coast,
    input ea,
    input eb,
    input[1:0] st_pins,
    output st_in,
    output IN1,
    output IN2,
    output IN3,
    output IN4,
    output ENA,
    output ENB
//    output [5:0]DEBUG
);

   reg [14:0] ratioA_r, ratioB_r;
   reg [14:0] FULLSPEED = 32768/63;
   reg [5:0]  sw_REAL;
   wire [5:0] swb;
   
   
//   assign DEBUG = swb;
   
   always @(*)
   begin
   sw_REAL = ((Direction == 3'b010)||(Direction == 3'b110)||(Direction == 3'b100)) ? (45):(sw); //Full speed for reverse or turning
   ratioA_r = ((Direction == 3'b111)||(Direction == 3'b101)) ? (0):(32768/63); // Half speeds for turning FL/FR/BL/BR
   ratioB_r = ((Direction == 3'b001)||(Direction == 3'b011)) ? (0):(32768/63); // Can be changed for Independant motor operation
   end
   
//    Encoder Speedcontrol (
//        .clk(clk),
//        .brake(brake),
//        .coast(coast),
//        .Adjust(Adjust),
//        .ea(ea),
//        .eb(eb),
//        .direction(Direction),
//        .sw(sw),
//        .swb(swb)
//    );
    
    PWM speedB (
        .clk(clk),
        .ratio(ratioB_r),
        .brake(brake),
        .coast(coast),
        .sw(sw_REAL),
        .enable(ENB)
    );
    
    PWM speedA (
        .clk(clk),
        .ratio(ratioA_r),
        .brake(brake),
        .coast(coast),
        .sw(sw_REAL),
        .enable(ENA)
    );
    
    stall stall_detect (
        .clk(clk),
        .st_pins(st_pins),
        .st_in(st_in)
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
