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
    input FB,
    input LR,
    input brake,
    output IN1,
    output IN2,
    output IN3,
    output IN4
    );
     
     // FB = 1; Forward
     // LR = 1; Left
     // LR = 0; Right
     // FB = 0; Backward
     
    reg DirA_r, DirB_r; 
   
    always @(*)
    begin
        if (FB)
        begin
            DirA_r <= 1;
            DirB_r <= 1;
        end
        if (LR)
        begin
            DirA_r <= 1;
            DirB_r <= 0;
        end
        if (~LR)
        begin
            DirA_r <= 0;
            DirB_r <= 1;
        end
        if (~FB)
        begin
            DirA_r <= 0;
            DirB_r <= 0;
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
