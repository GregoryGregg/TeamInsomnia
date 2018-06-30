`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2018 11:39:31 AM
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
// Revision 0.02 - added seven seg and io (Justin)
// Additional Comments: More info in seven_sev.v
// 
//////////////////////////////////////////////////////////////////////////////////


module TopModule(
    input clk,
    output[3:0] an,
    output[6:0] seg


    );
    
    wire[15:0] msg; //wire for the message for the seven seg
    
     seven_seg Useven_seg( //instantiate the seven seg display
      .clk (clk),
      .msg (msg),
      .an  (an),
      .seg (seg)
     );
    
endmodule
