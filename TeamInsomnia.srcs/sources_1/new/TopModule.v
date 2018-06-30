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
    input JA0, //echo from ultrasonic
    output[3:0] an, //anode for seven seg
    output[6:0] seg, //segment for seven seg
    output JA1 //trigger for ultrasonic
    

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
      
     
    
endmodule
