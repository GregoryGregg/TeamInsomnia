`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2018 01:07:31 PM
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
// Revision 0.03 - added ultrasonic and io (Justin)
// Additional Comments: More info in ultrasonic_proximity.v
// 
//////////////////////////////////////////////////////////////////////////////////


module TopModule(
    input clk,
    input [2:0]direction,
    input [5:0]sw, // Speed for the motor control module set by the switches, to be removed
    input brake, // to be removed in favor of a register in the code
    input coast, // to be removed as with brake
    input JA0, //echo from ultrasonic
    output[3:0] an, //anode for seven seg
    output[6:0] seg, //segment for seven seg
    output JA1, //trigger for ultrasonic
    output IN1, // All that follow are motor outputs and shouldn't be moved
    output IN2, 
    output IN3,
    output IN4,
    output ENA,
    output ENB
);
    
    wire[15:0] msg; //wire for the message for the seven seg
    wire[15:0] dist; //distance from proximity sensor
    
     seven_seg Useven_seg( //instantiate the seven seg display
        .clk (clk),
        .msg (msg),
        .an  (an),
        .seg (seg)
     );
     
     ultrasonic_proximity Uultrasonic_proximity( //instantiate the ultrasonic sensor
        .clk  (clk),
        .echo  (JA0),
        .trigger  (JA1),
        .dist (dist)
      );
      
      // Motor control instantiaiton, Keep this at the bottom
      Motor_Control Surface (
        .Direction(direction),
        .clk(clk),
        .sw(sw),    // to be removed 
        .brake(brake),
        .coast(coast),
        .IN1(IN1),
        .IN2(IN2),
        .IN3(IN3),
        .IN4(IN4),
        .ENA(ENA),
        .ENB(ENB)
     );
     
    
endmodule
