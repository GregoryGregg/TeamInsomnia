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
     // Forward.........= 000
     // Forward-Right...= 001
     // Right...........= 010
     // Back-Right......= 011
     // Back............= 100
     // Back-Left.......= 101
     // Left............= 110
     // Forward-Left... = 111 
     
    reg DirA_r, DirB_r; 
   
    always @(*)
    begin
    
      case(Direction)
      //Forwards and turning
      3'b000, 3'b001, 3'b111:
        begin
            DirA_r <= 1;
            DirB_r <= 0;
        end
      3'b100, 3'b011, 3'b101:
        begin
            DirA_r <= 0;
            DirB_r <= 1;
        end
      3'b110:
        begin
            DirA_r <= 0;
            DirB_r <= 0;
        end
      3'b010:
        begin
            DirA_r <= 1;
            DirB_r <= 1;
        end
        endcase
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
