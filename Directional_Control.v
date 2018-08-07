`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2018 11:05:39 PM
// Design Name: 
// Module Name: Directional_Control
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


module Directional_Control(
   input direction,
   input brake,
   output INA,
   output INB
   );
   
   reg INA_r,INB_r; 
   
   assign INA = INA_r;
   assign INB = INB_r;
   
   always @(*)
   begin
       if (brake)
       begin   
           INA_r <= 0;
           INB_r <= 0;
       end
       else
       begin
           INA_r <= direction;
           INB_r <= ~direction;
       end
   end
endmodule
