`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Name: Justin Schwausch
// Class: ECE 3331
// Project: Stall Detection
// Target: Basys 3 Board
// Last Modified: 8/03/2018
//
// This program takes in two stall detection pins from the rover chassis and determines if the rover has stalled.
//
// The program takes a sample of the stall pins to minimize false triggers.
//////////////////////////////////////////////////////////////////////////////////


module stall(
    input clk,
    input[1:0] st_pins,
    output st_in
    );
    
    reg[24:0] const = 25'b1111111001010000001010101;
    reg[24:0] count;
    reg stall_l;
    reg stall_r;
    reg stall;
    
    assign st_in = stall;
    
    always @(posedge clk)
    begin
    
    stall_l <= st_pins[0];
    stall_r <= st_pins[1];
    
    end
    
    always @(posedge clk)
    begin
    
    if(st_pins[0] || st_pins[1])
    begin
    
    count <= count + 1'b1;
    
    end
    
    else
    begin
    
    count <= 25'b0;
    
    end
    
    if(count >= const)
    begin
    
    stall <= 1'b1;
    count <= 25'b0;
    
    end
    
    else
    begin
    
    stall <= 1'b0;
    
    end
    
    end
    
endmodule
