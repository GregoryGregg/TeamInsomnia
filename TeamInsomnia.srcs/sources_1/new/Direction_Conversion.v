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
        if (direction == 2'b11)
        begin
            DirA_r <= 1;
            DirB_r <= 1;
        end
        if (direction == 2'b10)
        begin
            DirA_r <= 1;
            DirB_r <= 0;
        end
        if (direction == 2'b01)
        begin
            DirA_r <= 0;
            DirB_r <= 1;
        end
        if (direction == 2'b00)
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
