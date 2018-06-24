`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2018 11:55:22 PM
// Design Name: 
// Module Name: Direction_Conversion
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


module Direction_Conversion(
    input direction,
    input brake,
    output IN1,
    output IN2,
    output IN3,
    output IN4
    );
     
     // FORWARD = 11
     // ROTATION = 10
     // ANTIROTATION = 01
     // BACKWARD = 00
     
    reg DirA_r, DirB_r; 
   
    always @(*)
    begin
        if (direction == 2'b00)
            Dir
        
    
endmodule
