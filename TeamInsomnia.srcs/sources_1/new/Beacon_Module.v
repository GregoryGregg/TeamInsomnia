`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2018 12:46:03 PM
// Design Name: 
// Module Name: Beacon_Module
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

module Beacon_Module(
    input clk,
    input micLeft,
    input micRight,
    output[2:0]direction,
    output MICCHECK
    );

reg check;
reg micRight_reg;  
reg micLeft_reg;
reg direction_reg;
reg direction_regms;
reg direction_fin;
reg [2:0]MotorDirection_r;
reg[15:0] countLeft;
reg[15:0] countRight;

reg[9:0] hist;
reg update = 1'b0;
reg directionbit;

always @(posedge micLeft)       // We save the value of micRight at every posedge of micLeft
    begin
    micRight_reg <= micRight;
    end

always @(posedge clk)           // Every time the clk rises, we set direction to the value of micRight at the rising edge of
//                                 micLeft. We do this because if micRight = 1 at the rising edge of micLeft, this means micRight
//                                 was already 1 and heard the signal first. If micRight = 0 at the rising edge of micLeft, this
//                                 means micRight hasn't been heard even though micLeft is. This shows micLeft hears the signal first.
    begin
    direction_reg <= micRight_reg;      // If micRight is heard first, set direction = 1. if micLeft is heard first, set direction=0.
    end

always @(posedge clk)                   // Repeat to maintain metastability.
    begin
    direction_regms <= direction_reg;
    end

always @(posedge clk)
begin
    
    if(!micLeft)
    begin
    countLeft <= 16'b0;
    update <= 1'b0;
    end
    else
    begin
    countLeft <= countLeft + 1;
    end
    
    if(!micRight)
    begin
    countRight <= 1'b0;
    update <= 1'b0;
    end
    else
    begin
    countRight <= countRight + 1;
    end
    
    if(countLeft >= 9200 && countLeft <= 10800 && countRight >= 9200 && countRight <= 10800)
    begin
    update <= 1'b1;
    direction_fin <= direction_regms;
    end
    
end
    
    
always @(posedge clk)
    begin
    if (directionbit) begin
    MotorDirection_r <= 3'b001;
    end else if (directionbit<=0) begin
    MotorDirection_r <= 3'b111;
    end else begin
    MotorDirection_r <= 3'b000;
    end

    end
    
assign MICCHECK = directionbit;     
assign direction = MotorDirection_r;       // direction =0 means go left. direction =1 means go right

    always @(posedge clk) //average code
    begin
       
       if(update)
       begin
       
       hist <= hist >> 1;
       
       hist[9] <= direction_fin; //make the lsb in history current direction
       
       if((hist[0] + hist[1] + hist[2] + hist[3] + hist[4] + hist[5] + hist[6] + hist[7] + hist[8] + hist[9] >= 4)) //if three or more of the last five us readings are high
       begin
       directionbit <= 1'b1; //warn of obstacle
       end
       
       else
       begin
       directionbit <= 1'b0; //is no obstacle
       end
       
    end
    
    end
endmodule

