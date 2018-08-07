`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2018 11:08:29 PM
// Design Name: 
// Module Name: Braking
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


module Braking(
input direction,
input brake,
output INA,
output INB,
output INC,
output IND
    );
    
    //create and assign registers
    reg INA_r,INB_r,INC_r,IND_r;
    
    assign INA = INA_r;
    assign INB = INB_r;
    assign INC = INC_r;
    assign IND = IND_r;
    
    always @(*)
    begin
        if (brake) //if the brake is on all outputs to H-bridge go to zero
        begin
            INA_r <= 0;
            INB_r <= 0;
            INC_r <= 0;
            IND_r <= 0;
        end
        else
        begin
            
            Motor_Control WhichWay (
            );
            
        end
    end
endmodule
