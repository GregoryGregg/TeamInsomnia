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
    input [2:0]Direction,
    input brake,
    output IN1,
    output IN2,
    output IN3,
    output IN4
    );
     
     // This is a 3-bit register so there is going to be 8 possible directions
     // Forward = 111
     // Back = 000
     // Left = 100
     // Right = 001
     // Forward-Left = 110
     // Forward-Right = 011
     // Back-Left = 101
     // Back-Right = 010
     
    reg DirA_r, DirB_r; 
   
    always @(*)
    begin
        if (S)
        begin
            if (FB)
            begin
                DirA_r <= 1;
                DirB_r <= 0;
            end
            if (~FB)
            begin
                DirA_r <= 0;
                DirB_r <= 1;
            end
        end
        else
        begin
            if (LR)
            begin
                DirA_r <= 0;
                DirB_r <= 0;
            end
            if (~LR)
            begin
                DirA_r <= 1;
                DirB_r <= 1;
            end
        end    
    end
    
    Directional_Control MotorA(
        .direction(DirA_r),
        .brake(brake),
        .INA(IN1),
        .INB(IN2)
        );
        
    Directional_Control MotorB(
        .direction(DirB_r),
        .brake(brake),
        .INA(IN3),
        .INB(IN4)
        );
    
endmodule
